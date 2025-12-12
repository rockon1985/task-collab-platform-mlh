require 'rails_helper'

RSpec.describe 'Api::V1::Comments', type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:task) { create(:task, project: project, creator: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: user.id)}" } }

  describe 'GET /api/v1/tasks/:task_id/comments' do
    let!(:comment1) { create(:comment, task: task, user: user, content: 'First comment') }
    let!(:comment2) { create(:comment, task: task, user: user, content: 'Second comment') }

    context 'with valid authentication' do
      it 'returns all comments for the task' do
          get "/api/v1/tasks/#{task.id}/comments", headers: auth_headers

        expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json.length).to eq(2)
      end

      it 'includes user information' do
          get "/api/v1/tasks/#{task.id}/comments", headers: auth_headers

          json = JSON.parse(response.body)
          expect(json.first).to have_key('user')
          expect(json.first['user']['id']).to eq(user.id)
      end

        it 'orders comments by creation date (most recent first)' do
          get "/api/v1/tasks/#{task.id}/comments", headers: auth_headers

          json = JSON.parse(response.body)
          expect(json.first['content']).to eq('Second comment')
          expect(json.last['content']).to eq('First comment')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
          get "/api/v1/tasks/#{task.id}/comments"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'for unauthorized project' do
      let(:other_user) { create(:user) }
      let(:other_auth_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: other_user.id)}" } }

      it 'returns forbidden' do
          get "/api/v1/tasks/#{task.id}/comments", headers: other_auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/tasks/:task_id/comments' do
    let(:valid_params) do
      {
        comment: {
          content: 'This is a new comment'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new comment' do
        expect {
            post "/api/v1/tasks/#{task.id}/comments",
               params: valid_params.to_json,
               headers: auth_headers.merge({ 'Content-Type' => 'application/json' })
        }.to change(Comment, :count).by(1)
      end

      it 'returns created comment' do
          post "/api/v1/tasks/#{task.id}/comments",
             params: valid_params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json['content']).to eq('This is a new comment')
          expect(json['user']['id']).to eq(user.id)
      end

      it 'creates activity log' do
        expect {
            post "/api/v1/tasks/#{task.id}/comments",
               params: valid_params.to_json,
               headers: auth_headers.merge({ 'Content-Type' => 'application/json' })
        }.to change(ActivityLog, :count).by_at_least(1)
      end

      it 'enqueues notification job' do
        assignee = create(:user)
        create(:project_membership, project: project, user: assignee)
        task.update(assignee: assignee)

        expect(CommentNotificationJob).to receive(:perform_later).with(kind_of(Integer))

          post "/api/v1/tasks/#{task.id}/comments",
             params: valid_params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for empty body' do
        invalid_params = { comment: { content: '' } }
          post "/api/v1/tasks/#{task.id}/comments",
             params: invalid_params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:unprocessable_content)
          json = JSON.parse(response.body)
          expect(json['errors']).to include("Content can't be blank")
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
          post "/api/v1/tasks/#{task.id}/comments",
             params: valid_params.to_json,
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:task_id/comments/:id' do
    let(:comment) { create(:comment, task: task, user: user, content: 'Original comment') }
    let(:update_params) do
      {
        comment: {
          content: 'Updated comment text'
        }
      }
    end

    context 'as comment owner' do
      it 'updates the comment' do
          patch "/api/v1/tasks/#{task.id}/comments/#{comment.id}",
              params: update_params.to_json,
              headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['content']).to eq('Updated comment text')
      end

      # No explicit edited flag; content change verified above
    end

    context 'as another user' do
      let(:other_user) { create(:user) }
      let!(:other_member) { create(:project_membership, project: project, user: other_user, role: 'member') }
      let(:other_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: other_user.id)}" } }

      it 'returns forbidden' do
          patch "/api/v1/tasks/#{task.id}/comments/#{comment.id}",
              params: update_params.to_json,
              headers: other_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid parameters' do
      it 'returns errors' do
        invalid_params = { comment: { content: '' } }
          patch "/api/v1/tasks/#{task.id}/comments/#{comment.id}",
              params: invalid_params.to_json,
              headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /api/v1/tasks/:task_id/comments/:id' do
    let(:comment) { create(:comment, task: task, user: user) }

    context 'as comment owner' do
      it 'deletes the comment' do
        comment_to_delete = create(:comment, task: task, user: user)

        expect {
            delete "/api/v1/tasks/#{task.id}/comments/#{comment_to_delete.id}",
                 headers: auth_headers
        }.to change(Comment, :count).by(-1)
      end

      it 'returns no content' do
          delete "/api/v1/tasks/#{task.id}/comments/#{comment.id}",
               headers: auth_headers

        expect(response).to have_http_status(:no_content)
      end

      # No activity log on delete; model only logs on create
    end

    context 'as project manager' do
      let(:manager) { create(:user) }
      let!(:manager_member) { create(:project_membership, project: project, user: manager, role: 'manager') }
      let(:manager_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: manager.id)}" } }

      it 'cannot delete others comments (forbidden)' do
        delete "/api/v1/tasks/#{task.id}/comments/#{comment.id}",
               headers: manager_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'as another member' do
      let(:other_user) { create(:user) }
      let!(:other_member) { create(:project_membership, project: project, user: other_user, role: 'member') }
      let(:other_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: other_user.id)}" } }

      it 'returns forbidden' do
          delete "/api/v1/tasks/#{task.id}/comments/#{comment.id}",
               headers: other_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'for non-existent comment' do
      it 'returns not found' do
          delete "/api/v1/tasks/#{task.id}/comments/99999",
               headers: auth_headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

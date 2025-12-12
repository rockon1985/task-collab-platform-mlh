require 'rails_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: user.id)}" } }
  let(:task) { create(:task, project: project, creator: user) }

  describe 'GET /api/v1/projects/:project_id/tasks' do
    let!(:task1) { create(:task, project: project, creator: user, status: 'todo') }
    let!(:task2) { create(:task, project: project, creator: user, status: 'done') }

    context 'with valid authentication' do
      it 'returns all tasks for the project' do
        get "/api/v1/projects/#{project.id}/tasks", headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
      end

      it 'filters tasks by status' do
        get "/api/v1/projects/#{project.id}/tasks",
            params: { status: 'todo' },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first['status']).to eq('todo')
      end

      it 'filters tasks by assignee' do
        assignee = create(:user)
        create(:project_membership, project: project, user: assignee)
        assigned_task = create(:task, project: project, creator: user, assignee: assignee)

        get "/api/v1/projects/#{project.id}/tasks",
            params: { assignee_id: assignee.id },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first['assignee']['id']).to eq(assignee.id)
      end

      it 'filters tasks by priority' do
        create(:task, project: project, creator: user, priority: 'high')
        create(:task, project: project, creator: user, priority: 'low')

        get "/api/v1/projects/#{project.id}/tasks",
            params: { priority: 'high' },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first['priority']).to eq('high')
      end

      it 'sorts tasks by priority' do
        create(:task, project: project, creator: user, priority: 'low', title: 'Low priority')
        create(:task, project: project, creator: user, priority: 'high', title: 'High priority')

        get "/api/v1/projects/#{project.id}/tasks",
            params: { sort_by: 'priority' },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.first['priority']).to eq('critical').or eq('high')
      end

      it 'sorts tasks by due_date' do
        create(:task, project: project, creator: user, due_date: 3.days.from_now)
        create(:task, project: project, creator: user, due_date: 1.day.from_now)

        get "/api/v1/projects/#{project.id}/tasks",
            params: { sort_by: 'due_date' },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to be >= 2
      end

      it 'sorts tasks by position' do
        create(:task, project: project, creator: user, position: 2)
        create(:task, project: project, creator: user, position: 1)

        get "/api/v1/projects/#{project.id}/tasks",
            params: { sort_by: 'position' },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to be >= 2
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get "/api/v1/projects/#{project.id}/tasks"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'for unauthorized project' do
      let(:other_user) { create(:user) }
      let(:other_auth_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: other_user.id)}" } }

      it 'returns forbidden' do
        get "/api/v1/projects/#{project.id}/tasks", headers: other_auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v1/projects/:project_id/tasks/:id' do
    context 'with valid authentication' do
      it 'returns task details' do
        get "/api/v1/projects/#{project.id}/tasks/#{task.id}", headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(task.id)
        expect(json['title']).to eq(task.title)
      end

      it 'includes task relationships' do
        get "/api/v1/projects/#{project.id}/tasks/#{task.id}", headers: auth_headers

        json = JSON.parse(response.body)
        expect(json).to have_key('creator')
        expect(json).to have_key('project')
      end
    end

    context 'for non-existent task' do
      it 'returns not found' do
        get "/api/v1/projects/#{project.id}/tasks/99999", headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks' do
    let(:valid_params) do
      {
        task: {
          title: 'New Task',
          description: 'Task description',
          status: 'todo',
          priority: 'high',
          due_date: 1.week.from_now.to_date
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new task' do
        expect {
          post "/api/v1/projects/#{project.id}/tasks",
               params: valid_params.to_json,
               headers: auth_headers.merge({ 'Content-Type' => 'application/json' })
        }.to change(Task, :count).by(1)
      end

      it 'returns created task' do
        post "/api/v1/projects/#{project.id}/tasks",
             params: valid_params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('New Task')
        expect(json['creator']['id']).to eq(user.id)
      end

      it 'assigns task to specified user' do
        assignee = create(:user)
        create(:project_membership, project: project, user: assignee)

        params = valid_params.deep_merge(task: { assignee_id: assignee.id })
        post "/api/v1/projects/#{project.id}/tasks",
             params: params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        json = JSON.parse(response.body)
        expect(json['assignee']['id']).to eq(assignee.id)
      end

      it 'creates activity log' do
        # Expecting 2 activity logs: task creation + owner membership
        expect {
          post "/api/v1/projects/#{project.id}/tasks",
               params: valid_params.to_json,
               headers: auth_headers.merge({ 'Content-Type' => 'application/json' })
        }.to change(ActivityLog, :count).by_at_least(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for missing title' do
        invalid_params = { task: { description: 'No title' } }
        post "/api/v1/projects/#{project.id}/tasks",
             params: invalid_params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Title can't be blank")
      end

      it 'returns errors for past due date' do
        invalid_params = valid_params.deep_merge(task: { due_date: 1.day.ago.to_date })
        post "/api/v1/projects/#{project.id}/tasks",
             params: invalid_params.to_json,
             headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Due date can't be in the past")
      end
    end

    context 'without proper permissions' do
      let(:viewer) { create(:user) }
      let!(:viewer_member) { create(:project_membership, project: project, user: viewer, role: 'viewer') }
      let(:viewer_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: viewer.id)}" } }

      it 'returns forbidden' do
        post "/api/v1/projects/#{project.id}/tasks",
             params: valid_params.to_json,
             headers: viewer_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/tasks/:id' do
    let(:update_params) do
      {
        task: {
          title: 'Updated Title',
          status: 'in_progress',
          priority: 'critical'
        }
      }
    end

    context 'with valid parameters' do
      it 'updates the task' do
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
              params: update_params.to_json,
              headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('Updated Title')
        expect(json['status']).to eq('in_progress')
      end

      it 'updates assignee' do
        assignee = create(:user)
        create(:project_membership, project: project, user: assignee)

        params = { task: { assignee_id: assignee.id } }
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
              params: params.to_json,
              headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        json = JSON.parse(response.body)
        expect(json['assignee']['id']).to eq(assignee.id)
      end

      it 'creates activity log for status change' do
        params = { task: { status: 'done' } }

        expect {
          patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
                params: params.to_json,
                headers: auth_headers.merge({ 'Content-Type' => 'application/json' })
        }.to change(ActivityLog, :count).by_at_least(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns errors' do
        invalid_params = { task: { title: '' } }
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
              params: invalid_params.to_json,
              headers: auth_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'without proper permissions' do
      let(:viewer) { create(:user) }
      let!(:viewer_member) { create(:project_membership, project: project, user: viewer, role: 'viewer') }
      let(:viewer_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: viewer.id)}" } }

      it 'returns forbidden' do
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
              params: update_params.to_json,
              headers: viewer_headers.merge({ 'Content-Type' => 'application/json' })

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks/:id/assign' do
    let(:assignee) { create(:user) }
    let!(:membership) { create(:project_membership, project: project, user: assignee) }

    context 'with valid assignee' do
      it 'assigns the task to the user' do
        post "/api/v1/projects/#{project.id}/tasks/#{task.id}/assign",
             params: { assignee_id: assignee.id },
             headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['assignee']['id']).to eq(assignee.id)
      end

      it 'enqueues notification job' do
        expect(TaskAssignmentNotificationJob).to receive(:perform_later).with(task.id, assignee.id)

        post "/api/v1/projects/#{project.id}/tasks/#{task.id}/assign",
             params: { assignee_id: assignee.id },
             headers: auth_headers
      end
    end

    context 'with invalid assignee' do
      let(:non_member) { create(:user) }

      it 'returns unprocessable content' do
        post "/api/v1/projects/#{project.id}/tasks/#{task.id}/assign",
             params: { assignee_id: non_member.id },
             headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end
    end

    context 'when task is already assigned to user' do
      before { task.update(assignee: assignee) }

      it 'returns unprocessable content' do
        post "/api/v1/projects/#{project.id}/tasks/#{task.id}/assign",
             params: { assignee_id: assignee.id },
             headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'without proper permissions' do
      let(:viewer) { create(:user) }
      let!(:viewer_member) { create(:project_membership, project: project, user: viewer, role: 'viewer') }
      let(:viewer_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: viewer.id)}" } }

      it 'returns forbidden' do
        post "/api/v1/projects/#{project.id}/tasks/#{task.id}/assign",
             params: { assignee_id: assignee.id },
             headers: viewer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/tasks/:id' do
    context 'with proper permissions' do
      it 'deletes the task' do
        task_to_delete = create(:task, project: project, creator: user)

        expect {
          delete "/api/v1/projects/#{project.id}/tasks/#{task_to_delete.id}",
                 headers: auth_headers
        }.to change(Task, :count).by(-1)
      end

      it 'returns no content' do
        delete "/api/v1/projects/#{project.id}/tasks/#{task.id}",
               headers: auth_headers

        expect(response).to have_http_status(:no_content)
      end

      it 'creates activity log' do
        expect {
          delete "/api/v1/projects/#{project.id}/tasks/#{task.id}",
                 headers: auth_headers
        }.to change(ActivityLog, :count).by_at_least(1)
      end
    end

    context 'without proper permissions' do
      let(:viewer) { create(:user) }
      let!(:viewer_member) { create(:project_membership, project: project, user: viewer, role: 'viewer') }
      let(:viewer_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: viewer.id)}" } }

      it 'returns forbidden' do
        delete "/api/v1/projects/#{project.id}/tasks/#{task.id}",
               headers: viewer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

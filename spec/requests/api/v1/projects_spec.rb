require 'rails_helper'

RSpec.describe 'Api::V1::Projects', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'GET /api/v1/projects' do
    before do
      create_list(:project, 3, owner: user)
      create(:project) # Another user's project
    end

    it 'returns user projects' do
      get '/api/v1/projects', headers: headers

      expect(response).to have_http_status(:success)
      expect(json_response.length).to eq(3)
    end

    it 'excludes archived projects by default' do
      create(:project, :archived, owner: user)

      get '/api/v1/projects', headers: headers

      expect(json_response.length).to eq(3)
    end

    it 'includes archived projects when requested' do
      create(:project, :archived, owner: user)

      get '/api/v1/projects', headers: headers, params: { include_archived: 'true' }

      expect(json_response.length).to eq(4)
    end
  end

  describe 'GET /api/v1/projects/:id' do
    let(:project) { create(:project, owner: user) }

    it 'returns project details' do
      get "/api/v1/projects/#{project.id}", headers: headers

      expect(response).to have_http_status(:success)
      expect(json_response['id']).to eq(project.id)
      expect(json_response['name']).to eq(project.name)
    end

    it 'returns forbidden for unauthorized access' do
      other_project = create(:project)

      get "/api/v1/projects/#{other_project.id}", headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_params) do
      {
        project: {
          name: 'New Project',
          description: 'Project description'
        }
      }
    end

    it 'creates a new project' do
      expect {
        post '/api/v1/projects', params: valid_params, headers: headers
      }.to change(Project, :count).by(1)
    end

    it 'sets current user as owner' do
      post '/api/v1/projects', params: valid_params, headers: headers

      project = Project.last
      expect(project.owner).to eq(user)
    end

    it 'returns created project' do
      post '/api/v1/projects', params: valid_params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json_response['name']).to eq('New Project')
    end

    it 'returns errors for invalid params' do
      post '/api/v1/projects', params: { project: { name: 'Ab' } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response).to have_key('errors')
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    let(:project) { create(:project, owner: user) }

    it 'updates project' do
      patch "/api/v1/projects/#{project.id}",
            params: { project: { name: 'Updated Name' } },
            headers: headers

      expect(response).to have_http_status(:success)
      expect(project.reload.name).to eq('Updated Name')
    end

    it 'returns forbidden for unauthorized update' do
      other_project = create(:project)

      patch "/api/v1/projects/#{other_project.id}",
            params: { project: { name: 'Hacked' } },
            headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, owner: user) }

    it 'deletes project' do
      expect {
        delete "/api/v1/projects/#{project.id}", headers: headers
      }.to change(Project, :count).by(-1)
    end

    it 'returns no content' do
      delete "/api/v1/projects/#{project.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /api/v1/projects/:id/archive' do
    let(:project) { create(:project, owner: user) }

    it 'archives the project' do
      post "/api/v1/projects/#{project.id}/archive", headers: headers

      expect(project.reload.status).to eq('archived')
      expect(project.archived_at).to be_present
    end
  end

  describe 'GET /api/v1/projects/:id/analytics' do
    let(:project) { create(:project, :with_tasks, owner: user) }

    it 'returns project analytics' do
      get "/api/v1/projects/#{project.id}/analytics", headers: headers

      expect(response).to have_http_status(:success)
      expect(json_response).to include('total_tasks', 'completion_rate', 'tasks_by_status')
    end
  end
end

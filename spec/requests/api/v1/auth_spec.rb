require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  describe 'POST /api/v1/auth/register' do
    let(:valid_params) do
      {
        user: {
          email: 'newuser@example.com',
          password: 'Password123!',
          password_confirmation: 'Password123!',
          first_name: 'John',
          last_name: 'Doe'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/auth/register', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns user data and token' do
        post '/api/v1/auth/register', params: valid_params

        expect(response).to have_http_status(:created)
        expect(json_response).to include('user', 'token')
        expect(json_response['user']['email']).to eq('newuser@example.com')
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for missing fields' do
        post '/api/v1/auth/register', params: { user: { email: 'test@example.com' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end

      it 'returns error for duplicate email' do
        create(:user, email: 'existing@example.com')
        params = valid_params.deep_merge(user: { email: 'existing@example.com' })

        post '/api/v1/auth/register', params: params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'Password123!') }

    context 'with valid credentials' do
      it 'returns user and token' do
        post '/api/v1/auth/login', params: {
          auth: { email: 'user@example.com', password: 'Password123!' }
        }

        expect(response).to have_http_status(:success)
        expect(json_response).to include('user', 'token')
      end

      it 'updates last_login_at' do
        expect {
          post '/api/v1/auth/login', params: {
            auth: { email: 'user@example.com', password: 'Password123!' }
          }
        }.to change { user.reload.last_login_at }.from(nil)
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post '/api/v1/auth/login', params: {
          auth: { email: 'user@example.com', password: 'WrongPassword' }
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid credentials')
      end

      it 'returns unauthorized for non-existent user' do
        post '/api/v1/auth/login', params: {
          auth: { email: 'nonexistent@example.com', password: 'Password123!' }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:user) { create(:user) }

    context 'with valid token' do
      it 'returns current user data' do
        get '/api/v1/auth/me', headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['email']).to eq(user.email)
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        get '/api/v1/auth/me'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

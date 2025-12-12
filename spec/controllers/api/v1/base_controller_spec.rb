require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(Api::V1::BaseController) do
    def test_pagination
      render json: pagination_params
    end
  end

  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{AuthenticationService.encode_token(user_id: user.id)}" } }

  before do
    routes.draw do
      get 'test_pagination' => 'api/v1/base#test_pagination'
    end
  end

  describe '#pagination_params' do
    it 'returns default pagination parameters' do
      request.headers.merge!(auth_headers)
      get :test_pagination

      json = JSON.parse(response.body)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(25)
    end

    it 'returns provided page parameter' do
      request.headers.merge!(auth_headers)
      get :test_pagination, params: { page: 3 }

      json = JSON.parse(response.body)
      expect(json['page']).to eq(3)
    end

    it 'returns provided per_page parameter' do
      request.headers.merge!(auth_headers)
      get :test_pagination, params: { per_page: 50 }

      json = JSON.parse(response.body)
      expect(json['per_page']).to eq(50)
    end

    it 'caps per_page at 100' do
      request.headers.merge!(auth_headers)
      get :test_pagination, params: { per_page: 200 }

      json = JSON.parse(response.body)
      expect(json['per_page']).to eq(100)
    end

    it 'uses default when per_page is nil' do
      request.headers.merge!(auth_headers)
      get :test_pagination, params: { per_page: nil }

      json = JSON.parse(response.body)
      expect(json['per_page']).to eq(25)
    end
  end

  describe '#append_info_to_payload' do
    it 'adds user info to payload when user is authenticated' do
      request.headers.merge!(auth_headers)

      allow(controller).to receive(:current_user).and_return(user)

      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload[:user_id]).to eq(user.id)
      expect(payload).to have_key(:ip)
    end
  end
end

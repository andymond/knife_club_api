require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      render json: { message: 'Test message' }
    end
  end

  let(:password) { '1Password!' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:token) { ApiSessionManager.new(user.id).try_login(password)[:token] }
  let(:headers) { { 'User' => user.id, 'Authorization' => token } }

  describe '#authenticate' do
    it 'authenticates valid requests' do
      request.headers.merge!(headers)
      get :index
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response).to eq({ message: 'Test message' })
    end

    it 'rejects invalid requests' do
      get :index

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to eq({ errors: 'Invalid Credential' })
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe V1::PasswordResetsController do
  let(:user) { create(:user) }


  describe '#create' do
    it 'creates token' do
      post :create, params: { email: user.email }

      expect(response).to have_http_status(:created)
      expect(user.reload.reset_password_token).to be_a(String)
      expect(user.reload.reset_password_token_expires_at).to be_a(ActiveSupport::TimeWithZone)
    end
  end

  context 'user token valid' do
    before { user.deliver_reset_password_instructions! }

    describe '#edit' do
      it 'resonds successfully with correct token' do
        get :edit, params: { token: user.reset_password_token }

        expect(response).to have_http_status(:ok)
      end
    end

    describe '#update' do
      let(:password_params) do
        { password: 'password3', password_confirmation: 'password3' }
      end

      it 'succeeds & changes password' do
        og_password = user.crypted_password

        put :update, params: { user: password_params, token: user.reset_password_token }

        expect(response).to have_http_status(:ok)
        expect(user.reload.crypted_password).not_to eq(og_password)
      end
    end
  end

  context 'user token invalid or missing' do
    it "fails" do
      get :edit, params: { token: 'badtoken' }

      expect(response).to have_http_status(:bad_request)
    end

    it "fails" do
      get :edit, params: { token: '' }

      expect(response).to have_http_status(:bad_request)
    end

    it "fails" do
      put :update, params: { token: 'badtoken' }

      expect(response).to have_http_status(:bad_request)
    end

    it "fails" do
      put :update

      expect(response).to have_http_status(:bad_request)
    end
  end
end

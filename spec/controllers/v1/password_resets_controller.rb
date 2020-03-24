require 'rails_helper'

describe V1::PasswordResetsController do
  let(:user) { create(:user) }

  context 'user token valid' do
    describe '#create' do
      before { post :create }

      it { expect(response).to have_http_status(:created) }
    end

    describe '#edit' do
      before do
        allow(User).to receive(:load_from_reset_password_token).and_return(user)
        get :edit, params: { id: user.id }
      end

      it { expect(response).to have_http_status(:ok) }
    end

    describe '#update' do
      let(:password_params) { { password: 'password3', password_confirmation: 'password3' } }

      before do
        allow(User).to receive(:load_from_reset_password_token).and_return(user)
        put :update, params: { user: password_params }
      end

      it { expect(response).to have_http_status(:ok) }
    end
  end

  context 'user not returned from token' do
    describe '#edit' do
    end

    describe '#update' do
    end
  end
end

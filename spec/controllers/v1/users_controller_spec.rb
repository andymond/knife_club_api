# frozen_string_literal: true

require 'rails_helper'

describe V1::UsersController do
  let(:valid_user_params) do
    { email: 'test@user.com',
      password: 'Password1!',
      password_confirmation: 'Password1!' }
  end

  let(:missing_param) { %i[email password password_confirmation] }

  describe '#create' do
    context 'valid user registration credentials' do
      before { post :create, params: { user: valid_user_params } }

      it { expect(response).to have_http_status(:created) }

      it {
        expect(JSON.parse(response.body)).to eq({
                                                  'user' => User.last.id,
                                                  'msg' => 'Created User'
                                                })
      }
    end

    context 'invalid user registration credentials' do
      it 'Sends failure with error' do
        missing = missing_param.sample
        post :create, params: { user: valid_user_params.except(missing) }

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:conflict)
        expect(json_response.keys).to include(missing)
      end
    end
  end

  context 'existing authenticated user' do
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:authenticate).and_return(true)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    describe '#show' do
      it 'allows current user to view their own info' do
        get :show, params: { id: current_user.id }

        expect(response).to have_http_status(:ok)
      end

      it 'does not allow current user to view other user' do
        get :show, params: { id: other_user.id }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe '#update' do
      it 'allows current user to update their own info' do
        put :update, params: { id: current_user.id, user: { email: 'new_email@email.com' } }

        expect(response).to have_http_status(:ok)
      end

      it 'does not allow current user to update other user' do
        put :update, params: { id: other_user.id, email: 'new_email@email.com' }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe '#destroy' do
      it 'allows current user to soft delete themselves' do
        delete :destroy, params: { id: current_user.id }

        expect(response).to have_http_status(:ok)
        expect(User.find_by(id: current_user.id)).to eq(nil)
      end

      it 'does not allow current user to delete other user' do
        delete :destroy, params: { id: other_user.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

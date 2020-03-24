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
                                                  'msg' => 'Created Account'
                                                })
      }
    end

    context 'invalid user registration credentials' do
      before { post :create, params: { user: valid_user_params.except(missing_param.sample) } }

      it { expect(response).to have_http_status(:conflict) }

      it 'Sends failure with error' do
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(json_response[:msg]).to include('Create Failed')
      end
    end
  end
end

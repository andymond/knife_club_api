# frozen_string_literal: true

require 'swagger_helper'

describe 'Sessions API' do
  path '/v1/sessions' do
    let!(:user) { create(:user, password: '1!Password', password_confirmation: '1!Password') }

    post 'Log User In' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        }
      }

      response '201', 'Logged User In' do
        let(:credentials) { { email: user.email, password: '1!Password' } }
        schema name: :login, in: :body, schema: {
          type: :object,
          properties: {
            token: { type: :string }
          }
        }
        examples login: { token: '1234567890' }

        run_test!
      end

      response '401', 'Invalid Credentials' do
        let(:credentials) { { email: user.email, password: 'idk' } }
        schema '$ref' => '#/definitions/msg'
        examples '$ref' => '#/definitions/msg'

        run_test!
      end

      response '403', 'User Locked Out' do
        before do
          lockout = { status: 403, msg: 'No more login attempts, please try again later.' }
          allow_any_instance_of(ApiSessionManager).to receive(:try_login).and_return(lockout)
        end

        let(:credentials) { {} }
        schema '$ref' => '#/definitions/msg'
        examples '$ref' => '#/definitions/msg'

        run_test!
      end
    end

    delete 'Log User Out' do
      tags 'Sessions'
      security [{ api_key: [] }, { user_id: [] }]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'Logged User Out' do
        let(:token) { ApiSessionManager.new(user.id).try_login('1!Password')[:token] }
        let(:User) { user.id }
        let(:Authorization) { token }
        before { allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user) }

        schema '$ref' => '#/definitions/msg'
        examples '$ref' => '#/definitions/msg'

        run_test!
      end

      response '401', 'Logout Failed' do
        schema '$ref' => '#/definitions/msg'
        examples '$ref' => '#/definitions/msg'

        run_test!
      end
    end
  end
end

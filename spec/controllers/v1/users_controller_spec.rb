require 'rails_helper'

describe V1::UsersController do
  let(:valid_user_params) {
    { email: "test@user.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    }
  }

  let(:missing_param) { [:email, :password, :password_confirmation] }

  describe "#create" do
    context "valid user registration credentials" do
      before { post :create, params: { user: valid_user_params } }

      it { expect(response).to have_http_status(201) }
      it { expect(JSON.parse(response.body)).to eq({ "success" => User.last.id }) }
    end

    context "invalid user registration credentials" do
      before { post :create, params: { user: valid_user_params.except(missing_param.sample) } }

      it { expect(response).to have_http_status(409) }
      it { expect(JSON.parse(response.body)).to eq({ "failure" => "user creation failed" })}
    end
  end
end
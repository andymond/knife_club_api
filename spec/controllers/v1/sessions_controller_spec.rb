require "rails_helper"

describe V1::SessionsController, type: :controller do
  let(:user) { create(:user, password: "coolpassword", password_confirmation: "coolpassword") }
  let(:token) { ApiSessionManager.new(user.id).try_login("coolpassword")[:token] }
  let(:auth_headers) { { "User" => user.id, "Authorization" => token } }

  describe "#create" do
    it "logs user in, creates session & returns token" do
      post :create, params: { email: user.email, password: "coolpassword" }
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(201)
      expect(json_response[:token].blank?).to eq(false)
      expect(user.api_session).to be_an_instance_of(UserApiSession)
      expect(user.api_session.api_token_last_verified).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(BCrypt::Password.new(user.api_session.api_token_digest)).to eq(json_response[:token])
    end

    it "doesn't accept invalid credentials" do
      post :create, params: { email: user.email, password: "fakepassword" }
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(401)
      expect(json_response[:msg]).to eq("Invalid Credentials")
      expect(user.api_session.api_token_digest).to eq(nil)
      expect(user.api_session.api_token_last_verified).to eq(nil)
    end
  end

  describe "#destroy" do
    it "logs user out" do
      request.headers.merge(auth_headers)
      delete :destroy
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(200)
      expect(json_response[:msg]).to eq("Logged user out.")
    end

    it "needs api authentication to log user out" do
      delete :destroy, params: { email: user.email }
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(401)
      expect(json_response).to eq({ errors: "Invalid Credential" })
    end
  end
end

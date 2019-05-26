require "rails_helper"

describe V1::SessionsController, type: :controller do
  let(:user) { create(:user, password: "coolpassword", password_confirmation: "coolpassword") }

  describe "#create" do
    it "logs user in, creates session & returns token" do
      post :create, params: { email: user.email, password: "coolpassword" }
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(200)
      expect(json_response[:token].blank?).to eq(false)
      expect(user.api_session).to be_an_instance_of(UserApiSession)
      expect(user.api_session.api_token_last_verified).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(BCrypt::Password.new(user.api_session.api_token_digest)).to eq(json_response[:token])
    end

    it "doesn't accept invalid credentials" do
      post :create, params: { email: user.email, password: "fakepassword" }
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(401)
      expect(json_response[:message]).to eq("Invalid Credentials")
      expect(user.api_session.api_token_digest).to eq(nil)
      expect(user.api_session.api_token_last_verified).to eq(nil)
    end
  end
end

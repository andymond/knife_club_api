require "rails_helper"

describe V1::CookbooksController, type: :controller do
  context "#create" do
    let(:user) { create(:user, password: "coolpassword", password_confirmation: "coolpassword") }
    let(:token) { ApiSessionManager.new(user.id).try_login("coolpassword")[:token] }
    let(:auth_headers) { { "User" => user.id, "Authorization" => token } }
    let(:create_request) { post :create, params: { name: "Test Cookbook" } }
    before { request.headers.merge(auth_headers) }

    it { expect{ create_request }.to change { Cookbook.count }.by 1 }
    it { expect{ create_request }.to change { Section.count }.by 1 }

    it "returns serialized cookbook" do
      create_request
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(json_response[:id]).to be_an(Integer)
      expect(json_response[:name]).to eq("Test Cookbook")
      expect(json_response[:public]).to eq(false)
    end
  end
end

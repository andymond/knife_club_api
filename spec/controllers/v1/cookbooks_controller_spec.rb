require "rails_helper"

describe V1::CookbooksController, type: :controller do
  let(:user) { create(:user, password: "coolpassword", password_confirmation: "coolpassword") }
  let(:token) { ApiSessionManager.new(user.id).try_login("coolpassword")[:token] }
  let(:auth_headers) { { "User" => user.id, "Authorization" => token } }

  describe "#create" do
    let(:create_request) { post :create, params: { name: "Test Cookbook" } }
    before { request.headers.merge(auth_headers) }

    it { expect{ create_request }.to change { user.cookbooks.count }.by 1 }
    it { expect{ create_request }.to change{ user.user_roles.where(role: Role.owner).count }.by 1 }
    it { expect{ create_request }.to change { Section.count }.by 1 }

    it "returns serialized cookbook" do
      create_request
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(json_response[:id]).to be_an(Integer)
      expect(json_response[:name]).to eq("Test Cookbook")
      expect(json_response[:public]).to eq(false)
    end
  end

  let(:user_2) { create(:user, password: "coolpassword", password_confirmation: "coolpassword") }
  let(:token_2) { ApiSessionManager.new(user_2.id).try_login("coolpassword")[:token] }
  let(:auth_headers_2) { { "User" => user_2.id, "Authorization" => token_2 } }

  describe "#show" do
    context "cookbook is public" do
      let(:public_cookbook) { user.create_cookbook(name: "Indian Food", public: true) }
      let(:create_public_cb_request) { get :show, params: { id: public_cookbook.id } }

      it "allows user to view cookbook" do
        request.headers.merge(auth_headers_2)
        create_public_cb_request

        expect(response).to have_http_status(200)
      end
    end

    context "cookbook is private" do
      let(:private_cookbook) { user.create_cookbook(name: "Top Secret Sauces") }
      let(:create_private_cb_request) { get :show, params: { id: private_cookbook.id } }

      it "allows user with permission to view cookbook" do
        request.headers.merge(auth_headers)
        create_private_cb_request

        expect(response).to have_http_status(200)
      end

      it "prevents user without permission from viewing cookbook" do
        request.headers.merge(auth_headers_2)
        create_private_cb_request

        expect(response).to have_http_status(404)
      end
    end

    context "cookbook doesn't exist" do
      before { request.headers.merge(auth_headers) }

      it "returns 404" do
        get :show, params: { id: "x" }

        expect(response).to have_http_status(404)
      end
    end
  end
end

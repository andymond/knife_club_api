require "rails_helper"

describe V1::CookbooksController, type: :controller do
  let(:owner) { create(:user, password: "opassword", password_confirmation: "opassword") }
  let(:o_token) { ApiSessionManager.new(owner.id).try_login("opassword")[:token] }
  let(:owner_headers) { { "User" => owner.id, "Authorization" => o_token } }

  let(:contributor) { create(:user, password: "cpassword", password_confirmation: "cpassword") }
  let(:c_token) { ApiSessionManager.new(contributor.id).try_login("cpassword")[:token] }
  let(:contributor_headers) { { "User" => contributor.id, "Authorization" => c_token } }

  let(:reader) { create(:user, password: "rpassword", password_confirmation: "rpassword") }
  let(:r_token) { ApiSessionManager.new(reader.id).try_login("rpassword")[:token] }
  let(:reader_headers) { { "User" => reader.id, "Authorization" => r_token } }

  let(:unassociated) { create(:user, password: "upassword", password_confirmation: "upassword") }
  let(:u_token) { ApiSessionManager.new(unassociated.id).try_login("upassword")[:token] }
  let(:unassoc_headers) { { "User" => unassociated.id, "Authorization" => u_token } }

  let(:random_headers) { [owner_headers, contributor_headers, reader_headers, unassoc_headers].sample }

  before(:each) do
    if defined?(cookbook)
      contributor.allow_contributions_to(cookbook.id)
      reader.allow_to_read(cookbook.id)
    end
  end

  describe "#create" do
    let(:create_request) { post :create, params: { name: "Test Cookbook" } }
    before { request.headers.merge(owner_headers) }

    it { expect{ create_request }.to change { owner.cookbooks.count }.by 1 }
    it { expect{ create_request }.to change{ owner.user_cookbook_roles.where(role: Role.owner).count }.by 1 }
    it { expect{ create_request }.to change { Section.count }.by 1 }

    it "returns serialized cookbook" do
      create_request
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(json_response[:id]).to be_an(Integer)
      expect(json_response[:name]).to eq("Test Cookbook")
      expect(json_response[:public]).to eq(false)
    end
  end

  describe "#show" do
    context "cookbook is public" do
      let(:cookbook) { owner.create_cookbook(name: "Indian Food", public: true) }
      let(:create_public_cb_request) { get :show, params: { id: cookbook.id } }

      it "allows anyone to view cookbook" do
        request.headers.merge(random_headers)
        create_public_cb_request

        expect(response).to have_http_status(200)
      end
    end

    context "cookbook is private" do
      let(:cookbook) { owner.create_cookbook(name: "Top Secret Sauces") }
      let(:create_private_cb_request) { get :show, params: { id: cookbook.id } }

      it "allows owner to view cookbook" do
        request.headers.merge(owner_headers)
        create_private_cb_request

        expect(response).to have_http_status(200)
      end

      it "allows readers to view cookbook" do
        request.headers.merge(reader_headers)
        create_private_cb_request

        expect(response).to have_http_status(200)
      end

      it "prevents unassociated from viewing cookbook" do
        request.headers.merge(unassoc_headers)
        create_private_cb_request

        expect(response).to have_http_status(404)
      end
    end

    context "cookbook doesn't exist" do
      it "returns 404" do
        request.headers.merge(random_headers)

        get :show, params: { id: "x" }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe "#update" do
    context "cookbook is public" do
      let(:cookbook) { owner.create_cookbook(name: "Indian Food", public: true) }
      let(:create_public_cb_request) { put :update, params: { id: cookbook.id, name: "Not Indian Food" } }

      it "allows owner to update cookbook" do
        request.headers.merge(owner_headers)
        create_public_cb_request

        expect(response).to have_http_status(200)
      end

      it "allows contributors to update cookbook" do
        request.headers.merge(contributor_headers)
        create_public_cb_request

        expect(response).to have_http_status(200)
      end

      it "prevents user without permission from updating cookbook" do
        request.headers.merge(reader_headers)
        create_public_cb_request

        expect(response).to have_http_status(404)
      end

      it "prevents user without permission from updating cookbook" do
        request.headers.merge(unassoc_headers)
        create_public_cb_request

        expect(response).to have_http_status(404)
      end
    end

    context "cookbook is private" do
      let(:cookbook) { owner.create_cookbook(name: "Top Secret Sauces") }
      let(:create_private_cb_request) { put :update, params: { id: cookbook.id, name: "Extra Secret Sauces" } }

      it "allows owner to update cookbook" do
        request.headers.merge(owner_headers)
        create_private_cb_request

        expect(response).to have_http_status(200)
      end

      it "allows contributors to update cookbook" do
        request.headers.merge(contributor_headers)
        create_private_cb_request

        expect(response).to have_http_status(200)
      end

      it "prevents read_only from updating cookbook" do
        request.headers.merge(reader_headers)
        create_private_cb_request

        expect(response).to have_http_status(404)
      end

      it "prevents user without permission from updating cookbook" do
        request.headers.merge(unassoc_headers)
        create_private_cb_request

        expect(response).to have_http_status(404)
      end
    end

    context "cookbook doesn't exist" do
      before { request.headers.merge(owner_headers) }

      it "returns 404" do
        put :update, params: { id: "x", name: "Cookbook that doesn't exist"}

        expect(response).to have_http_status(404)
      end
    end
  end
end

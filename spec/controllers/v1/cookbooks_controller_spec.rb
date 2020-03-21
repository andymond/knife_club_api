require "rails_helper"

describe V1::CookbooksController, type: :controller do
  let(:owner) { create(:user) }
  let(:contributor) { create(:user) }
  let(:reader) { create(:user) }
  let(:rando) { create(:user) }
  let(:public_cookbook) { create(:cookbook, public: true) }
  let(:private_cookbook) { create(:cookbook, public: false) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate).and_return(true)
    owner.grant_all_access(private_cookbook)
    owner.grant_all_access(public_cookbook)
    contributor.allow_contributions_to(private_cookbook)
    contributor.allow_contributions_to(public_cookbook)
    reader.allow_to_read(private_cookbook)
  end

  context "any authd user" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando)
    end

    describe "#create" do
      let(:create_request) { post :create, params: { name: "Test Cookbook" } }

      it { expect{ create_request }.to change { rando.cookbooks.count }.by 1 }
      it { expect{ create_request }.to change{ rando.user_cookbook_roles.where(role: Role.owner).count }.by 1 }
      it { expect{ create_request }.to change { Section.count }.by 1 }

      it "returns serialized cookbook" do
        response = create_request
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(201)
        expect(json_response[:id]).to be_an(Integer)
        expect(json_response[:name]).to eq("Test Cookbook")
        expect(json_response[:public]).to eq(false)
      end
    end
  end

  context "user owns cookbook" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(owner)
    end

    context "cookbook is private" do
      it "can #show" do
        get :show, params: { id: private_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(payload[:id]).to eq(private_cookbook.id)
      end

      it "#can update" do
        put :update, params: { id: private_cookbook.id, name: "Updated Name" }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(payload[:name]).to eq("Updated Name")
        expect(private_cookbook.reload.name).to eq("Updated Name")
      end

      it "can #destroy" do

      end
    end
  end

  context "user contributes to cookbook" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(contributor)
    end

    context "cookbook is private" do
      it "can #show" do
        get :show, params: { id: private_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(payload[:id]).to eq(private_cookbook.id)
      end

      it "#can update" do
        put :update, params: { id: private_cookbook.id, name: "Updated Name" }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(payload[:name]).to eq("Updated Name")
        expect(private_cookbook.reload.name).to eq("Updated Name")
      end

      it "can not #destroy" do

      end
    end
  end

  context "user can read cookbook" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(reader)
    end

    context "cookbook is private" do
      it "can #show" do
        get :show, params: { id: private_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(payload[:id]).to eq(private_cookbook.id)
      end

      it "#can not update" do
        put :update, params: { id: private_cookbook.id, name: "Updated Name" }

        expect(response).to have_http_status(404)
        expect(private_cookbook.reload.name).not_to eq("Updated Name")
      end

      it "can not #destroy" do

      end
    end
  end

  context "user is not associated with cookbook," do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(rando)
    end

    context "cookbook is private," do
      it "can not #show" do
        get :show, params: { id: private_cookbook.id }

        expect(response).to have_http_status(404)
      end

      it "#can not update" do
        put :update, params: { id: private_cookbook.id, name: "Updated Name" }

        expect(response).to have_http_status(404)
      end

      it "can not #destroy" do

      end
    end

    context "cookbook is public" do
      it "can #show" do
        get :show, params: { id: public_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(payload[:id]).to eq(public_cookbook.id)
      end

      it "#can not update" do
        put :update, params: { id: public_cookbook.id, name: "Updated Name" }

        expect(response).to have_http_status(404)
      end

      it "can not #destroy" do

      end
    end
  end







  xdescribe "#destroy" do
    let(:cookbook) { owner.create_permission_record(Cookbook, { name: "Indian Food", public: [true, false].sample }) }
    let(:create_cb_request) { delete :destroy, params: { id: cookbook.id, name: "Not Indian Food" } }

    it "allows owner to delete cookbook" do
      request.headers.merge(owner_headers)
      create_cb_request

      expect(response).to have_http_status(200)
    end

    it "prevents contributors from deleting cookbook" do
      request.headers.merge(contributor_headers)
      create_cb_request

      expect(response).to have_http_status(404)
    end

    it "prevents read_only from deleting cookbook" do
      request.headers.merge(reader_headers)
      create_cb_request

      expect(response).to have_http_status(404)
    end
  end
end

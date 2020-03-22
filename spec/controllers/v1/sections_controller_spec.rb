require "rails_helper"

describe V1::SectionsController do
  let(:owner) { create(:user) }
  let(:contributor) { create(:user) }
  let(:reader) { create(:user) }
  let(:rando) { create(:user) }
  let(:cookbook) { create(:cookbook) }
  let(:section) { create(:section, cookbook: cookbook) }
  let(:recipe) { create(:recipe, section: cookbook.general_section) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate).and_return(true)
    owner.grant_all_access(cookbook)
    owner.grant_all_access(recipe)
    contributor.allow_contributions_to(cookbook)
    contributor.allow_contributions_to(recipe)
    reader.allow_to_read(cookbook)
  end

  context "user owns cookbook" do
    it "can #create" do
      post :create, params: { cookbook_id: cookbook.id, name: "Created Section" }
      payload = JSON.parse(response.body, symbolize_names: true)

      expect(:response).to have_http_status(201)
      expect(payload[:section][:name]).to eq("Created Section")
    end

    context "can #update" do
      it "updates normal section" do
        put :update, params: { cookbook_id: cookbook.id, id: section.id, name: "Updated Section" }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(:response).to have_http_status(201)
        expect(payload[:section][:name]).to eq("Updated Section")
      end

      it "wont update general section" do
        put :update, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id, name: "Updated Section" }

        expect(:response).to have_http_status(403)
      end
    end

    context "can #destroy" do
      it "defaults to destroying section & moving recipes to general" do
        delete :destroy, params: { cookbook_id: cookbook.id, id: section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(:response).to have_http_status(200)
        expect(payload[:msg]).to eq("Destroyed #{section.name} and moved its recipes to #{cookbook.general_section.name}")
      end

      it "destroys section & moves recipes to different section if specified" do
        new_section = create(:section, cookbook: cookbook)
        delete :destroy, params: { cookbook_id: cookbook.id, id: section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(:response).to have_http_status(200)
        expect(payload[:msg]).to eq("Destroyed #{section.name} and moved its recipes to #{new_section.name}")
      end

      it "destroys section & its recipes if specified" do
        delete :destroy, params: { cookbook_id: cookbook.id, id: section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(:response).to have_http_status(200)
        expect(payload[:msg]).to eq("Destroyed #{section.name} and its recipes")
      end

      it "wont remove general section" do
        delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

        expect(:response).to have_http_status(403)
      end
    end
  end

  context "user contributes to cookbook" do
    it "can not #create" do
      post :create, params: { cookbook_id: cookbook.id, name: "Created Recipe"}

      expect(:response).to have_http_status(404)
    end

    it "can not #update" do
      put :update, params: { cookbook_id: cookbook.id, id: section.id, name: "Updated Section" }

      expect(:response).to have_http_status(404)
    end

    it "can not #destroy" do
      delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

      expect(:response).to have_http_status(404)
    end
  end

  context "user reads cookbook" do
    it "can not #create" do
      post :create, params: { cookbook_id: cookbook.id, name: "Created Recipe"}

      expect(:response).to have_http_status(404)
    end

    it "can not #update" do
      put :update, params: { cookbook_id: cookbook.id, id: section.id, name: "Updated Section" }

      expect(:response).to have_http_status(404)
    end

    it "can not #destroy" do
      delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

      expect(:response).to have_http_status(404)
    end

  end

  context "user unassociated with cookbook" do
    it "can not #create" do
      post :create, params: { cookbook_id: cookbook.id, name: "Created Recipe"}

      expect(:response).to have_http_status(404)
    end

    it "can not #update" do
      put :update, params: { cookbook_id: cookbook.id, id: section.id, name: "Updated Section" }

      expect(:response).to have_http_status(404)
    end

    it "can not #destroy" do
      delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

      expect(:response).to have_http_status(404)
    end
  end
end

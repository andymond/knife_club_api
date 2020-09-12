# frozen_string_literal: true

require 'rails_helper'

describe V1::SectionsController do
  let(:owner) { create(:user) }
  let(:contributor) { create(:user) }
  let(:reader) { create(:user) }
  let(:rando) { create(:user) }
  let(:cookbook) { create(:cookbook) }
  let(:section) { create(:section, cookbook: cookbook) }
  let(:recipe) { create(:recipe, section: cookbook.general_section) }
  let(:update_params) { { cookbook_id: cookbook.id, id: section.id, name: 'Updated' } }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    owner.grant_all_access(cookbook)
    owner.grant_all_access(recipe)
    contributor.allow_contributions_to(cookbook)
    contributor.allow_contributions_to(recipe)
    reader.allow_to_read(cookbook)
  end

  context 'user owns cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(owner)
    end

    it 'can #create' do
      post :create, params: { cookbook_id: cookbook.id, name: 'Created Section' }
      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(payload[:section][:name]).to eq('Created Section')
    end

    context 'can #update' do
      it 'updates normal section' do
        put :update, params: update_params
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:section][:name]).to eq(update_params[:name])
      end

      it 'wont update general section' do
        put :update, params: update_params.update(id: cookbook.general_section.id)

        expect(response).to have_http_status(:conflict)
      end
    end

    context 'can #destroy' do
      it 'defaults to destroying section & moving recipes to general' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:msg]).to eq(
          "Destroyed #{section.name} and moved its recipes to #{cookbook.general_section.name}"
        )
      end

      it 'destroys section & moves recipes to different section if specified' do
        new_section = create(:section, cookbook: cookbook)
        delete :destroy, params: { cookbook_id: cookbook.id, id: section.id, move_to: new_section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:msg]).to eq(
          "Destroyed #{section.name} and moved its recipes to #{new_section.name}"
        )
      end

      # it 'destroys section & its recipes if specified' do
      #   delete :destroy, params: { cookbook_id: cookbook.id, id: section.id, destroy_recipes: true }
      #   payload = JSON.parse(response.body, symbolize_names: true)
      # 
      #   expect(response).to have_http_status(:ok)
      #   expect(payload[:msg]).to eq("Destroyed #{section.name} and its recipes")
      # end

      it 'wont remove general section' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  context 'user contributes to cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(contributor)
    end

    it 'can not #create' do
      post :create, params: { cookbook_id: cookbook.id, name: 'Created Recipe' }

      expect(response).to have_http_status(:not_found)
    end

    it 'can not #update' do
      put :update, params: update_params

      expect(response).to have_http_status(:not_found)
    end

    xit 'can not #destroy' do
      delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'user reads cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(reader)
    end

    it 'can not #create' do
      post :create, params: { cookbook_id: cookbook.id, name: 'Created Recipe' }

      expect(response).to have_http_status(:not_found)
    end

    it 'can not #update' do
      put :update, params: update_params

      expect(response).to have_http_status(:not_found)
    end

    xit 'can not #destroy' do
      delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'user unassociated with cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(rando)
    end

    it 'can not #create' do
      post :create, params: { cookbook_id: cookbook.id, name: 'Created Recipe' }

      expect(response).to have_http_status(:not_found)
    end

    it 'can not #update' do
      put :update, params: update_params

      expect(response).to have_http_status(:not_found)
    end

    xit 'can not #destroy' do
      delete :destroy, params: { cookbook_id: cookbook.id, id: cookbook.general_section.id }

      expect(response).to have_http_status(:not_found)
    end
  end
end

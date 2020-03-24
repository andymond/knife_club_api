# frozen_string_literal: true

require 'rails_helper'

describe V1::RecipesController, type: :controller do
  let(:owner) { create(:user) }
  let(:contributor) { create(:user) }
  let(:reader) { create(:user) }
  let(:rando) { create(:user) }
  let(:cookbook) { create(:cookbook) }
  let(:recipe) { create(:recipe, section: cookbook.general_section) }

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

    context 'cookbook is private or public' do
      before { allow(recipe).to receive(:public).and_return([true, false].sample) }

      it 'can #create' do
        post :create, params: { cookbook_id: cookbook.id, name: 'Create Recipe' }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:created)
        expect(payload[:recipe][:name]).to eq('Create Recipe')
      end

      it 'can #show' do
        get :show, params: { cookbook_id: cookbook.id, id: recipe.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipe][:id]).to eq(recipe.id)
      end

      it 'can #index' do
        get :index, params: { cookbook_id: cookbook.id, section_id: cookbook.general_section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipes][0][:id]).to eq(recipe.id)
      end

      it '#can update' do
        put :update, params: { cookbook_id: cookbook.id, id: recipe.id, name: 'Updated Name' }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipe][:name]).to eq('Updated Name')
        expect(recipe.reload.name).to eq('Updated Name')
      end

      it 'can #destroy' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:ok)
        expect { recipe.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'user contributes to cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(contributor)
    end

    context 'cookbook is private or public' do
      before { allow(recipe).to receive(:public).and_return([true, false].sample) }

      it 'can #create' do
        post :create, params: { cookbook_id: cookbook.id, name: 'Create Recipe' }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:created)
        expect(payload[:recipe][:name]).to eq('Create Recipe')

        created_recipe = Recipe.find(payload[:recipe][:id])

        expect(contributor.owns?(created_recipe)).to eq(true)
        expect(owner.owns?(created_recipe)).to eq(true)
      end

      it 'can #show' do
        get :show, params: { cookbook_id: cookbook.id, id: recipe.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipe][:id]).to eq(recipe.id)
      end

      it 'can #index' do
        get :index, params: { cookbook_id: cookbook.id, section_id: cookbook.general_section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipes][0][:id]).to eq(recipe.id)
      end

      it '#can update' do
        put :update, params: { cookbook_id: cookbook.id, id: recipe.id, name: 'Updated Name' }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipe][:name]).to eq('Updated Name')
        expect(recipe.reload.name).to eq('Updated Name')
      end

      it 'can not #destroy' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:not_found)
        expect(recipe.reload.persisted?).to eq(true)
      end
    end
  end

  context 'user can read cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(reader)
    end

    context 'cookbook is private' do
      let(:create_request) { post :create, params: { cookbook_id: cookbook.id, name: 'Create Recipe' } }

      it { expect { create_request }.not_to change(Recipe, :count) }

      it 'can not #create' do
        create_request

        expect(response).to have_http_status(:not_found)
      end

      it 'can #show' do
        get :show, params: { cookbook_id: cookbook.id, id: recipe.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipe][:id]).to eq(recipe.id)
      end

      it 'can #index' do
        private_recipe = create(:recipe, public: false, section: cookbook.general_section)
        owner.grant_all_access(private_recipe)

        get :index, params: { cookbook_id: cookbook.id, section_id: cookbook.general_section.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:recipes][0][:id]).to eq(recipe.id)
        expect(payload[:recipes].count).to eq(1)
      end

      it '#can not update' do
        put :update, params: { cookbook_id: cookbook.id, id: recipe.id, name: 'Updated Name' }

        expect(response).to have_http_status(:not_found)
        expect(recipe.reload.name).not_to eq('Updated Name')
      end

      it 'can not #destroy' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:not_found)
        expect(recipe.reload.persisted?).to eq(true)
      end
    end
  end

  context 'user is not associated with cookbook,' do
    before do
      allow(controller).to receive(:current_user).and_return(rando)
    end

    context 'cookbook is private' do
      let(:create_request) { post :create, params: { cookbook_id: cookbook.id, name: 'Create Recipe' } }

      it { expect { create_request }.not_to change(Recipe, :count) }

      it 'can not #create' do
        create_request

        expect(response).to have_http_status(:not_found)
      end

      it 'can not #show' do
        get :show, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:not_found)
      end

      it '#can not update' do
        put :update, params: { cookbook_id: cookbook.id, id: recipe.id, name: 'Updated Name' }

        expect(response).to have_http_status(:not_found)
      end

      it 'can not #destroy' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:not_found)
        expect(recipe.reload.persisted?).to eq(true)
      end
    end

    context 'cookbook is public' do
      before { allow(cookbook).to receive(:public).and_return(true) }

      let(:create_request) { post :create, params: { cookbook_id: cookbook.id, name: 'Create Recipe' } }

      it { expect { create_request }.not_to change(Recipe, :count) }

      it 'can not #create' do
        create_request

        expect(response).to have_http_status(:not_found)
      end

      it 'can not #show' do
        get :show, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:not_found)
      end

      it '#can not update' do
        put :update, params: { cookbook_id: cookbook.id, id: recipe.id, name: 'Updated Name' }

        expect(response).to have_http_status(:not_found)
      end

      it 'can not #destroy' do
        delete :destroy, params: { cookbook_id: cookbook.id, id: recipe.id }

        expect(response).to have_http_status(:not_found)
        expect(recipe.reload.persisted?).to eq(true)
      end
    end
  end
end

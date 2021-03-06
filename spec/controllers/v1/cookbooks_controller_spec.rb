# frozen_string_literal: true

require 'rails_helper'

describe V1::CookbooksController, type: :controller do
  let(:owner) { create(:user) }
  let(:contributor) { create(:user) }
  let(:reader) { create(:user) }
  let(:rando) { create(:user) }
  let(:public_cookbook) { create(:cookbook, public: true) }
  let(:private_cookbook) { create(:cookbook, public: false) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    owner.grant_all_access(private_cookbook)
    owner.grant_all_access(public_cookbook)
    contributor.allow_contributions_to(private_cookbook)
    contributor.allow_contributions_to(public_cookbook)
    reader.allow_to_read(private_cookbook)
    reader.allow_to_read(public_cookbook)
  end

  context 'any authd user' do
    before do
      allow(controller).to receive(:current_user).and_return(rando)
    end

    describe '#create' do
      let(:create_request) { post :create, params: { name: 'Test Cookbook' } }
      let(:owner_roles) { rando.user_cookbook_roles.where(role: Role.owner) }

      it { expect { create_request }.to change { rando.cookbooks.count }.by 1 }
      it { expect { create_request }.to change(owner_roles, :count).by 1 }
      it { expect { create_request }.to change(Section, :count).by 1 }

      it 'returns serialized cookbook' do
        response = create_request
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:created)
        expect(payload[:cookbook][:id]).to be_an(Integer)
        expect(payload[:cookbook][:name]).to eq('Test Cookbook')
        expect(payload[:cookbook][:public]).to eq(false)
        expect(payload[:cookbook][:sections].count).to eq(1)
      end
    end
  end

  context 'user owns cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(owner)
    end

    it 'can #index' do
      get :index
      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(payload[:cookbooks].count).to eq(2)
    end

    context 'cookbook is private' do
      it 'can #show' do
        get :show, params: { id: private_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbook][:id]).to eq(private_cookbook.id)
        expect(payload[:cookbook][:sections].count).to eq(1)
      end

      it '#can update' do
        put :update, params: { id: private_cookbook.id, name: 'Updated Name' }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbook][:name]).to eq('Updated Name')
        expect(private_cookbook.reload.name).to eq('Updated Name')
      end

      it 'can #destroy' do
        delete :destroy, params: { id: private_cookbook.id }

        expect(response).to have_http_status(:ok)
        expect { private_cookbook.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'user contributes to cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(contributor)
    end

    it 'can #index' do
      get :index
      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(payload[:cookbooks].count).to eq(2)
    end

    context 'cookbook is private' do
      it 'can #show' do
        get :show, params: { id: private_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbook][:id]).to eq(private_cookbook.id)
        expect(payload[:cookbook][:sections].count).to eq(1)
      end

      it '#can update' do
        put :update, params: { id: private_cookbook.id, name: 'Updated Name' }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbook][:name]).to eq('Updated Name')
        expect(private_cookbook.reload.name).to eq('Updated Name')
      end

      it 'can not #destroy' do
        delete :destroy, params: { id: public_cookbook.id }

        expect(response).to have_http_status(:not_found)
        expect(public_cookbook.reload.persisted?).to eq(true)
      end
    end
  end

  context 'user can read cookbook' do
    before do
      allow(controller).to receive(:current_user).and_return(reader)
    end

    it 'can #index' do
      get :index
      payload = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(payload[:cookbooks].count).to eq(2)
    end

    context 'cookbook is private' do
      it 'can #show' do
        get :show, params: { id: private_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbook][:id]).to eq(private_cookbook.id)
        expect(payload[:cookbook][:sections].count).to eq(1)
      end

      it '#can not update' do
        put :update, params: { id: private_cookbook.id, name: 'Updated Name' }

        expect(response).to have_http_status(:not_found)
        expect(private_cookbook.reload.name).not_to eq('Updated Name')
      end

      it 'can not #destroy' do
        delete :destroy, params: { id: public_cookbook.id }

        expect(response).to have_http_status(:not_found)
        expect(public_cookbook.reload.persisted?).to eq(true)
      end
    end
  end

  context 'user is not associated with cookbook,' do
    before do
      allow(controller).to receive(:current_user).and_return(rando)
    end

    describe '#index' do
      it 'no cookbooks if they dont have any' do
        get :index
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbooks].count).to eq(0)
      end
    end

    context 'cookbook is private,' do
      it 'can not #show' do
        get :show, params: { id: private_cookbook.id }

        expect(response).to have_http_status(:not_found)
      end

      it '#can not update' do
        put :update, params: { id: private_cookbook.id, name: 'Updated Name' }

        expect(response).to have_http_status(:not_found)
      end

      it 'can not #destroy' do
        delete :destroy, params: { id: private_cookbook.id }

        expect(response).to have_http_status(:not_found)
        expect(public_cookbook.reload.persisted?).to eq(true)
      end
    end

    context 'cookbook is public' do
      it 'can #show' do
        get :show, params: { id: public_cookbook.id }
        payload = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(payload[:cookbook][:id]).to eq(public_cookbook.id)
      end

      it '#can not update' do
        put :update, params: { id: public_cookbook.id, name: 'Updated Name' }

        expect(response).to have_http_status(:not_found)
      end

      it 'can not #destroy' do
        delete :destroy, params: { id: public_cookbook.id }

        expect(response).to have_http_status(:not_found)
        expect(public_cookbook.reload.persisted?).to eq(true)
      end
    end
  end
end

require 'rails_helper'
require 'swagger_helper'

describe 'Recipes API' do
  let(:cookbook) { create(:cookbook) }
  let(:cookbook_id) { cookbook.id }
  let(:password) { 'coolpassword' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:token) { ApiSessionManager.new(user.id).try_login(password)[:token] }
  let(:User) { user.id }
  let(:Authorization) { token }

  before { user.allow_contributions_to(cookbook) }

  path '/v1/cookbooks/{cookbook_id}/recipes' do
    parameter name: :cookbook_id, in: :path, schema: { type: :string }

    post 'Creates A Recipe' do
      tags 'Recipes'
      security [{ api_key: [] }, { user_id: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :recipe, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          public: { type: :boolean }
        },
        required: ['name']
      }

      response '201', 'Created' do
        let(:recipe) { { name: 'Makin Meatloaf with Meatloaf' } }

        schema '$ref' => '#/definitions/recipe'
        examples '$ref' => '#/definitions/recipe'

        run_test!
      end

      response '409', 'Creation Failed' do
        let(:recipe) { { bad_key: true } }
        run_test!
      end
    end

    get "Gets Cookbook's Recipes" do
      tags 'Recipes'
      security [{ api_key: [] }, { user_id: [] }]
      parameter name: :section_id, in: :query, type: :string, schema: { type: :string }, required: true

      response '200', 'Recipes' do
        let(:section_id) { cookbook.general_section.id }
        let(:recipe) { create(:recipe) }
        before { user.allow_to_read(recipe) }

        schema '$ref' => '#/definitions/recipe_list'
        examples '$ref' => '#/definitions/recipe_list'

        run_test!
      end
    end
  end

  path '/v1/cookbooks/{cookbook_id}/recipes/{id}' do
    parameter name: :cookbook_id, in: :path, schema: { type: :string }
    parameter name: :id, in: :path, schema: { type: :string }

    get 'Gets A Recipe' do
      tags 'Recipes'
      security [{ api_key: [] }, { user_id: [] }]
      produces 'application/json'

      response '200', 'Recipe' do
        let(:recipe) { create(:recipe, section: cookbook.general_section) }
        let(:id) { recipe.id }
        before { user.allow_to_read(cookbook) }

        schema '$ref' => '#/definitions/recipe'
        examples '$ref' => '#/definitions/recipe'

        run_test!
      end

      response '404', 'Not Found' do
        let(:id) { 'not-here' }
        run_test!
      end
    end

    put 'Update A Recipe' do
      tags 'Recipes'
      security [{ api_key: [] }, { user_id: [] }]
      produces 'application/json'

      response '200', 'Updated Recipe' do
        let(:recipe) { create(:recipe, section: cookbook.general_section) }
        let(:id) { recipe.id }
        before { [recipe, cookbook].each { |pr| user.allow_contributions_to(pr) } }

        schema '$ref' => '#/definitions/cookbook'
        examples '$ref' => '#/definitions/cookbook'

        run_test!
      end

      response '404', 'Not Found' do
        let(:id) { create(:recipe, section: cookbook.general_section).id }
        before { user.allow_to_read(cookbook) }

        run_test!
      end
    end

    delete "Remove User's Recipe" do
      tags 'Recipes'
      security [{ api_key: [] }, { user_id: [] }]

      response '200', 'Deleted Recipe' do
        let(:recipe) { create(:recipe, section: cookbook.general_section) }
        let(:id) { recipe.id }
        before { [recipe, cookbook].each { |pr| user.grant_all_access(pr) } }

        schema '$ref' => '#/definitions/cookbook'
        examples '$ref' => '#/definitions/cookbook'

        run_test!
      end

      response '404', 'Not Found' do
        let(:id) { 'nope' }
        before { user.allow_to_read(cookbook) }

        run_test!
      end
    end
  end
end

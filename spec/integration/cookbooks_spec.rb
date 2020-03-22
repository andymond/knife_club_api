require "rails_helper"
require "swagger_helper"

describe "Cookbooks API" do
  let(:password) { "coolpassword" }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:token) { ApiSessionManager.new(user.id).try_login(password)[:token] }
  let(:User) { user.id }
  let(:Authorization) { token }

  path "/v1/cookbooks" do
    post "Creates A Cookbook" do
      tags 'Cookbooks'
      security [ { api_key: [] }, { user_id: [] } ]
      consumes "application/json"
      parameter name: :cookbook, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          public: { type: :boolean }
        },
        required: ["name"]
      }

      response "201", "Created" do
        let(:cookbook) { { name: "Martha & Snoop At Home" } }

        schema "$ref" => "#/definitions/cookbook"
        examples "$ref" => "#/definitions/cookbook"

        run_test!
      end

      response "409", "Creation Failed" do
        let(:cookbook) { { public: true } }
        run_test!
      end
    end

    get "Gets Users Cookbooks" do
      tags 'Cookbooks'
      security [ { api_key: [] }, { user_id: [] } ]

      response "200", "Cookbooks" do
        let(:cookbook) { create(:cookbook) }
        before { user.allow_to_read(cookbook) }

        schema "$ref" => "#/definitions/cookbook_list"
        examples "$ref" => "#/definitions/cookbook_list"

        run_test!
      end

      response "404", "Not Found" do
        let(:cookbook) { create(:cookbook) }
        before { user.allow_to_read(cookbook) }

        schema "$ref" => "#/definitions/cookbook_list"
        examples "$ref" => "#/definitions/cookbook_list"

        run_test!
      end
    end
  end
end

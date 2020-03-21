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

      response "201", "Cookbook" do
        let(:cookbook) { { name: "Martha & Snoop At Home" } }
        run_test!
      end

      response "409", "Creation Failed" do
        let(:cookbook) { { public: true } }
        run_test!
      end
    end
  end
end

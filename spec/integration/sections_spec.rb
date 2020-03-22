require "swagger_helper"

describe "Sections API" do
  let(:cookbook) { create(:cookbook) }
  let(:cookbook_id) { cookbook.id }
  let(:password) { "coolpassword" }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:token) { ApiSessionManager.new(user.id).try_login(password)[:token] }
  let(:User) { user.id }
  let(:Authorization) { token }

  path "/v1/cookbooks/{cookbook_id}/sections" do
    post "Creates A Section" do
      parameter name: :section, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ["name"]
      }
      tags "Sections"
      security [ { api_key: [] }, { user_id: [] } ]
      consumes "application/json"
      produces "application/json"
    end
  end

  path "/v1/cookbooks/{cookbook_id}/sections/{id}" do
    let(:section) { create(:section, cookbook: cookbook) }
    let(:id) { section.id }
    parameter name: :cookbook_id, in: :path, schema: { type: :string }
    parameter name: :id, in: :path, schema: { type: :string }

    put "Updates A Section" do
      tags "Sections"
      security [ { api_key: [] }, { user_id: [] } ]
      consumes "application/json"
      produces "application/json"

      response "200", "Updated Section" do
        schema "$ref" => "#/definitions/section"
        example "$ref" => "#/definitions/section"

        run_test!
      end

      response "409", "Couldnt update section" do
        schema "$ref" => "#/definitions/msg"
        example "$ref" => "#/definitions/msg"

        run_test!
      end
    end

    delete "Removes A Section" do
      tags "Sections"
      security [ { api_key: [] }, { user_id: [] } ]
      consumes "application/json"
      produces "application/json"
      parameter name: :new_section_id, in: :path, schema: { type: :string }, required: :false

      response "200", "Deleted Section" do
        schema "$ref" => "#/definitions/msg"
        example "$ref" => "#/definitions/msg"

        run_test!
      end

      response "409", "Couldnt delete section" do
        schema "$ref" => "#/definitions/msg"
        example "$ref" => "#/definitions/msg"

        run_test!
      end
    end
  end
end

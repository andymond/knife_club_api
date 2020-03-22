require "swagger_helper"

describe "Users API" do
  path "/v1/users" do
    post "Register User" do
      tags 'Users'
      consumes "application/json"
      produces "application/json"
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              phone_number: { type: :string },
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string },
            }
          }
        },
        required: ["first_name", "email", "phone_number", "password", "password_confirmation"]
      }

      response "201", "Registered User" do
        let(:user) {
          {
            user: {
              first_name: "Cool",
              last_name: "User",
              email: "cool@user.com",
              phone_number: "",
              password: "1!Passsword",
              password_confirmation: "1!Passsword"
            }
          }
        }
        examples created: { msg: "Created Account", id: "1" }
        run_test!
      end

      response "409", "Registration Failed" do
        let(:user) { { user: { email: "cool" } } }
        schema "$ref" => "#/definitions/msg"
        examples "$ref" => "#/definitions/msg"

        run_test!
      end
    end
  end
end

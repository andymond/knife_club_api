require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      supportedSubmitMethods: [],
      info: {
        title: 'Knife Club API V1',
        version: 'v1'
      },
      securityDefinitions: {
        api_key: {
          type: :apiKey,
          name: 'Authorization',
          in: :header
        },
        user_id: {
          type: :apiKey,
          name: 'User',
          in: :header
        }
      },
      definitions: {
        msg: {
          type: :object,
          properties: {
            msg: { type: :string }
          }
        },
        cookbook_list: {
          type: :object,
            properties: {
              cookbooks: {
                type: :array,
                cookbook: { "$ref" => "#/definitions/cookbook" }
              }
            }
        },
        cookbook: {
          type: :object,
          properties: {
            sections: { type: :array },
            name: { type: :string },
            id: { type: :integer }
          }
        },
        recipe_list: {
          type: :object,
            properties: {
              recipes: {
                type: :array,
                cookbook: { "$ref" => "#/definitions/recipe" }
              }
            }
        },
        recipe: {
          type: :object,
          properties: {
            sections: { type: :array },
            name: { type: :string },
            id: { type: :integer }
          }
        },
        section: {
          type: :object,
          properties: {
            name: { type: :string }
          }
        },
        user: {
          type: :object,
          properties: {
            first_name: { type: :string },
            last_name: { type: :string },
            email: { type: :string },
            phone_number: { type: :string },
          }
        }
      },
      paths: {}
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end

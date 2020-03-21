class ApplicationController < ActionController::API
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :not_found

  before_action :authenticate
  attr_reader :current_user

  private
    def authenticate
      session_manager = ApiSessionManager.new(request.headers["User"])
      token = request.headers["Authorization"]
      if authenticated = session_manager.authenticate(token)
        @current_user = authenticated
      else
        render json: { errors: "Invalid Credential" }, status: 401
      end
    end

    def creation_failed(record)
      errors = record&.errors&.messages
      render json: { failure: "#{record&.class} creation failed - #{errors}" }, status: 409
    end

    def update_failed(record)
      errors = record&.errors&.messages
      render json: { failure: "#{record&.class} update failed - #{errors}" }, status: 409
    end

    def not_found
      head 404
    end
end

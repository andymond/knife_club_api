class ApplicationController < ActionController::API
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

    def creation_failed(model)
      errors = model&.errors&.messages
      render json: { failure: "#{model&.class} creation failed - #{errors}" }, status: 409
    end
end

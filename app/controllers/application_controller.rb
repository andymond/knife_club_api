class ApplicationController < ActionController::API
  before_action :authenticate

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

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
end

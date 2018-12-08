class ApplicationController < ActionController::API
  before_action :require_login
  private
    def require_login

    end
end

# frozen_string_literal: true

module V1
  class SessionsController < ApplicationController
    skip_before_action :authenticate, :authenticate, only: :create

    def create
      login_result = session_manager.try_login(params[:password])
      render json: login_result.except(:status), status: login_result[:status]
    end

    def destroy
      logout_result = session_manager.logout
      render json: logout_result.except(:status), status: logout_result[:status]
    end

    private

    def session_manager
      ApiSessionManager.new(current_user || user_from_params)
    end

    def user_from_params
      User.find_by(email: params[:email])
    end
  end
end

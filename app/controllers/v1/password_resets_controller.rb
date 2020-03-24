# frozen_string_literal: true

module V1
  class PasswordResetsController < ApplicationController
    skip_before_action :authenticate

    def create
      user = User.find_by(email: params[:email])
      user&.deliver_reset_password_instructions!
      render json: { msg: 'Password reset sent.' }, status: 201
    end

    def edit
      user = User.load_from_reset_password_token(params[:token])
      if user
        render :edit if user.present?
      else
        render json: { msg: 'Invalid Token' }, status: 400
      end
    end

    def update
      user = User.load_from_reset_password_token(params[:token])
      if user
        user.password_confirmation = change_params[:password_confirmation]
        user.change_password!(change_params[:password])
        render json: { msg: 'Password was successfully updated.' }, status: 200
      else
        render json: { msg: 'Invalid Token' }, status: 400
      end
    end

    private

    def change_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end

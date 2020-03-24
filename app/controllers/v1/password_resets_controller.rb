# frozen_string_literal: true

class V1::PasswordResetsController < ApplicationController
  def create
    @user = User.find_by(params[:email])
    @user&.deliver_reset_password_instructions!
    render json: { notice: 'Password reset sent.' }, status: 201
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])
    verify(@user)
    render :edit if @user.present?
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])
    verify(@user)

    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password!(params[:user][:password])
      render json: { notice: 'Password was successfully updated.' }, status: 200
    else
      render json: { failure: 'User password reset failed.' }, status: 409
    end
  end

  private

  def verify(user)
    if user.blank?
      render json: { error: 'User not found.' }, status: 404
      nil
    end
  end
end

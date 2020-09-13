# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    skip_before_action :authenticate, only: :create
    before_action :validate_user, only: %i[show update destroy]

    def create
      user = User.new(user_params)
      if user.save
        render json: { user: user.id, msg: 'Created User' }, status: 201
      else
        render json: user.errors.messages, status: 409
      end
    end

    def show
      render json: current_user
    end

    def update
      if current_user&.update(user_params)
        render json: current_user
      else
        render json: current_user.errors.messages, status: 409
      end
    end

    def destroy
      if current_user.destroy
        head 200
      else
        render json: current_user.errors.messages, status: 409
      end
    end

    private

    def user_params
      permitted = %i[first_name last_name phone_number email password password_confirmation]
      params.require(:user).permit(permitted)
    end

    def validate_user
      head 404 unless params[:id] == current_user.id.to_s
    end
  end
end

# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    skip_before_action :authenticate, only: :create

    def create
      user = User.new(user_params)
      if user.save
        created(user)
      else
        render json: { msg: 'Create Failed' }, status: 409
      end
    end

    private

    def user_params
      permitted = %i[first_name last_name phone_number email password password_confirmation]
      params.require(:user).permit(permitted)
    end

    def created(user)
      render json: { user: user.id, msg: 'Created Account' }, status: 201
    end
  end
end

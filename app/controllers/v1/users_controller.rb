class V1::UsersController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    user = User.new(user_params)
    user.save ? created(user) : creation_failed(user)
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password, :password_confirmation)
    end

    def created(user)
      render json: { success: user.id }, status: 201
    end
end

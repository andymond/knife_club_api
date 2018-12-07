class V1::UsersController < ApplicationController

  def create
    user = User.new(user_params)
    user.save ? created(user) : user_creation_failed
  end

  private

    def created(user)
      render json: { success: user.id }, status: 201
    end

    def user_creation_failed
      render json: { failure: 'user creation failed' }, status: 409
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password, :password_confirmation)
    end
end

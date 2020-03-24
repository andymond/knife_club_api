class V1::UsersController < ApplicationController
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
    params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password, :password_confirmation)
  end

  def created(user)
    render json: { user: user.id, msg: 'Created Account' }, status: 201
  end
end

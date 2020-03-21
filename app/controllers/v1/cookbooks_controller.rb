class V1::CookbooksController < ApplicationController
  def create
    cookbook = current_user.create_cookbook(cookbook_params)
    if cookbook.persisted?
      render json: cookbook, status: 201
    else
      creation_failed(cookbook)
    end
  end

  def show
    cookbook = Cookbook.find_by(id: params[:id])
    authorize cookbook
    render json: cookbook
  end

  def update
    cookbook = Cookbook.find_by(id: params[:id])
    authorize cookbook
    render json: cookbook
  end

  private
    def cookbook_params
      params.permit(:name, :public)
    end
end

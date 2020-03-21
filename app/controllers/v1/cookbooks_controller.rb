class V1::CookbooksController < ApplicationController
  def create
    cookbook = current_user.create_cookbook(cookbook_params)
    cookbook.persisted? ? respond_with(cookbook) : creation_failed(cookbook)
  end

  def show
    cookbook = Cookbook.find_by(id: params[:id])
    authorize cookbook
    respond_with(cookbook)
  end

  def update
    cookbook = Cookbook.find_by(id: params[:id])
    authorize cookbook
    respond_with(cookbook)
  end

  private
    def cookbook_params
      params.permit(:name, :public)
    end

    def respond_with(cookbook)
      render json: cookbook
    end
end

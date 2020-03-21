class V1::CookbooksController < ApplicationController
  def create
    cookbook = current_user.create_permission_record(Cookbook, cookbook_params)
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
    if cookbook.update(cookbook_params)
      render json: cookbook
    else
      update_failed(cookbook)
    end
  end

  def destroy
    cookbook = Cookbook.find_by(id: params[:id])
    authorize cookbook
    if cookbook.destroy
      render json: cookbook
    else
      update_failed(cookbook)
    end
  end

  private
    def cookbook_params
      params.permit(:name, :public)
    end
end

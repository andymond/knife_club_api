# frozen_string_literal: true

module V1
  class CookbooksController < ApplicationController
    def create
      cookbook = current_user.create_permission_record(Cookbook, cookbook_params)
      if cookbook.persisted?
        render json: cookbook, status: 201
      else
        render json: { msg: 'Create Failed' }, status: 409
      end
    end

    def show
      cookbook = Cookbook.find_by(id: params[:id])
      authorize cookbook
      render json: cookbook
    end

    def index
      render json: current_user.cookbooks
    end

    def update
      cookbook = Cookbook.find_by(id: params[:id])
      authorize cookbook
      if cookbook.update(cookbook_params)
        render json: cookbook
      else
        render json: { msg: 'Update Failed' }, status: 409
      end
    end

    def destroy
      cookbook = Cookbook.find_by(id: params[:id])
      authorize cookbook
      if cookbook.destroy
        render json: cookbook
      else
        render json: { msg: 'Update Failed' }, status: 409
      end
    end

    private

    def cookbook_params
      params.permit(:name, :public)
    end
  end
end

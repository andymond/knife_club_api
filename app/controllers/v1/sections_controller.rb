class V1::SectionsController < ApplicationController
  before_action :authorize_cookbook

  def create
    section = cookbook.sections.new(section_params)
    if section.save
      render json: section, status: 201
    else
      render json: { msg: "Create Failed" }, status: 409
    end
  end

  def update
    section = cookbook.sections.find_by(id: params[:id])
    if section&.update(section_params)
      render json: section, status: 200
    else
      render json: { msg: "Update Failed" }, status: 409
    end
  end

  private
    attr_reader :cookbook

    def section_params
      params.permit(:name)
    end

    def authorize_cookbook
      @cookbook = Cookbook.find(params[:cookbook_id])
      authorize cookbook, :owns?
    end
end

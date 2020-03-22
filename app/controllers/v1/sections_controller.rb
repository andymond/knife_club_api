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

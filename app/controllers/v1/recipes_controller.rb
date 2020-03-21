class V1::RecipesController < ApplicationController
  before_action :authorize_cookbook #skip for show

  def create
    recipe = current_user.create_permission_record(Recipe, recipe_params)
    if recipe.persisted?
      cookbook.owners.each { |ou| ou.grant_all_access(recipe) }
      cookbook.contributors.each { |cu| cu.allow_to_read(recipe) }
      render json: recipe, status: 201
    else
      creation_failed(recipe)
    end
  end

  private
    attr_reader :cookbook

    def recipe_params
      attrs = params.permit(:section_id, :name, :public)
      attrs[:section_id] = cookbook.general_section.id if attrs[:section_id].blank?
      attrs
    end

    def authorize_cookbook
      @cookbook = Cookbook.find(params[:cookbook_id])
      authorize cookbook, :update?
    end
end

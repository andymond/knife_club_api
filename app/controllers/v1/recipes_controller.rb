# frozen_string_literal: true

module V1
  class RecipesController < ApplicationController
    before_action :authorize_cookbook_update, except: %i[index show]
    before_action :authorize_cookbook_view, only: %i[index show]

    def create
      recipe = current_user.create_permission_record(Recipe, recipe_params)
      if recipe.persisted?
        cookbook.owners.each { |ou| ou.grant_all_access(recipe) }
        render json: recipe, status: 201
      else
        render json: { msg: 'Create Failed' }, status: 409
      end
    end

    def show
      recipe = Recipe.find_by(id: params[:id])
      authorize recipe
      render json: recipe
    end

  def index
    check_roles = "SELECT DISTINCT urr.id FROM user_recipe_roles urr WHERE urr.user_id = ?"
    has_permission = "recipes.public = true OR recipes.id IN (#{check_roles})"
    section_recipes = cookbook.sections.find(params[:section_id]).recipes
    recipes = section_recipes.where(has_permission, current_user.id).alphabetized
    render json: recipes
  end

    def update
      recipe = Recipe.find_by(id: params[:id])
      authorize recipe
      if recipe.update(recipe_params)
        render json: recipe
      else
        update_failed(recipe)
      end
    end

    def destroy
      recipe = Recipe.find_by(id: params[:id])
      authorize recipe
      if recipe.destroy
        render json: recipe
      else
        update_failed(recipe)
      end
    end

    private

    attr_reader :cookbook

    def recipe_params
      attrs = params.permit(:section_id, :name, :public)
      attrs[:section_id] = cookbook.general_section.id if attrs[:section_id].blank?
      attrs
    end

    def authorize_cookbook_update
      @cookbook = Cookbook.find(params[:cookbook_id])
      authorize cookbook, :update?
    end

    def authorize_cookbook_view
      @cookbook = Cookbook.find(params[:cookbook_id])
      authorize cookbook, :show?
    end
  end
end

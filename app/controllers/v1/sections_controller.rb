# frozen_string_literal: true

module V1
  class SectionsController < ApplicationController
    before_action :authorize_cookbook
    before_action :move_to, only: %(destroy)

    def create
      section = cookbook.sections.new(section_params)
      if section.save
        render json: section, status: 201
      else
        render json: { msg: 'Create Failed' }, status: 409
      end
    end

    def update
      section = cookbook.sections.find_by(id: params[:id])
      if section&.update(section_params)
        render json: section, status: 200
      else
        render json: { msg: 'Update Failed' }, status: 409
      end
    end

    def destroy
      section = cookbook.sections.find_by(id: params[:id])
      if section
        handle_general_destroy if section.general
        handle_destroy(section, cookbook.general_section) if !section.general && !move_to
        handle_destroy(section, move_to) if !section.general && move_to
      else
        head 404
      end
    end

    private

    attr_reader :cookbook

    def section_params
      params.permit(:name, :move_to)
    end

    def authorize_cookbook
      @cookbook = Cookbook.find(params[:cookbook_id])
      authorize cookbook, :owns?
    end

    def move_to
      Section.find_by(id: params[:move_to])
    end

    def handle_general_destroy
      render json: { msg: "Cannot destroy general section" }, status: 403
    end

    def handle_destroy(section, new_section)
      section.recipes.update_all(section_id: new_section.id, updated_at: DateTime.now)
      section.destroy
      msg = "Destroyed #{section.name} and moved its recipes to #{new_section.name}"
      render json: { msg: msg }
    end
  end
end

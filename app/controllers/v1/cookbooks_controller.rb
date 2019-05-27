class V1::CookbooksController < ApplicationController
  def create
    cookbook = current_user.cookbooks.new(cookbook_params)
    cookbook.save ? created(cookbook) : creation_failed(cookbook)
  end

  private
    def cookbook_params
      params.permit(:name, :public)
    end

    def created(cookbook)
      render json: cookbook
    end
end

class CategoriesController < ApplicationController
  skip_before_action :authorized, only: [:index]

  def index
    @categories = Category.all.order(:name)

    render json: @categories, each_serializer: CategorySerializer, status: :ok
  end
end

class UsersController < ApplicationController
  skip_before_action :authorized, only: [:create]

  def create
    @user = User.create!(user_params)
    if @user.valid?
      if @user.save
        token = encode_token({ user_id: @user.id })
        render json: { user: UserSerializer.new(@user), jwt: token }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def profile
    if @current_user
      render json: { user: UserSerializer.new(@current_user) }, status: :ok
    else
      render json: { message: "Please log in" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation)
  end
end

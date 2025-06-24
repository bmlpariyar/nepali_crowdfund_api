class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:create]

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      token = encode_token({ user_id: @user.id })
      @user.update(is_active: true) if @user.is_active == false
      render json: { user: UserSerializer.new(@user), jwt: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end

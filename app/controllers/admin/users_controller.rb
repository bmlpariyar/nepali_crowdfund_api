# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :update]

  # GET /admin/users
  def index
    @users = User.includes(:user_profile).order(created_at: :desc)
    render json: { users: ActiveModelSerializers::SerializableResource.new(@users, each_serializer: UserSerializer) }, status: :ok
  end

  # GET /admin/users/:id
  def show
    render json: { user: UserSerializer.new(@user).as_json }, status: :ok
  end

  # PUT /admin/users/:id
  def update
    if @user.update(admin_user_params)
      render json: { user: UserSerializer.new(@user).as_json }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def admin_user_params
    params.require(:user).permit(:full_name, :is_admin)
  end
end

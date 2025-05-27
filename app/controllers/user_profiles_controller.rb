class UserProfilesController < ApplicationController
  before_action :authorized
  before_action :set_user_profile

  def show
    render json: UserProfileSerializer.new(@user_profile).as_json, status: :ok
  end

  def update
    if @user_profile.update(user_profile_params)
      render json: UserProfileSerializer.new(@user_profile).as_json, status: :ok
    else
      render json: { errors: @user_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user_profile
    @user_profile = @current_user.user_profile || @current_user.build_user_profile
  end

  def user_profile_params
    params.require(:user_profile).permit(
      :bio,
      :location,
      :website_url,
      :profile_picture_url,
      :date_of_birth
    )
  end
end

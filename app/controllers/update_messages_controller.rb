class UpdateMessagesController < ApplicationController
  before_action :authorized, only: [:create]
  before_action :set_campaign

  def create
    @update_message = @campaign.update_messages.build(update_message_params)
    @update_message.user = @current_user

    if @update_message.save
      render json: { message: "Update posted successfully", update_message: UpdateMessageSerializer.new(@update_message).as_json }, status: :created
    else
      render json: { errors: @update_message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def get_update_messages
    @support_messages = @campaign.update_messages.order(created_at: :desc)
    render json: @support_messages, each_serializer: UpdateMessageSerializer, status: :ok
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def update_message_params
    params.require(:update_message).permit(:title, :message, :media_image)
  end
end

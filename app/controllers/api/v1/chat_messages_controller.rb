class Api::V1::ChatMessagesController < ApplicationController
  before_action :authorized
  before_action :set_campaign

  def index
    @chat_messages = @campaign.chat_messages
                              .includes(:user)
                              .chronological
                              .limit(100)

    render json: {
      message: "success",
      chat_messages: @chat_messages.map do |message|
        {
          id: message.id,
          message: message.message,
          sender_type: message.sender_type,
          sender_name: message.sender_name,
          created_at: message.created_at,
          read: message.read,
        }
      end,
    }, status: :ok
  end

  def create
    # Determine sender type
    sender_type = @current_user.id == @campaign.user_id ? "creator" : "donor"

    @chat_message = @campaign.chat_messages.build(chat_message_params)
    @chat_message.user = @current_user
    @chat_message.sender_type = sender_type

    if @chat_message.save
      receiver = @chat_message.sender_type == "creator" ? @campaign.donors.first : @campaign.user
      begin
        ChatMailer.new_message_notification(receiver, @chat_message).deliver_later
        Rails.logger.info "================================================"
        Rails.logger.info "Email sent successfully to #{receiver.email}"
      rescue => e
        Rails.logger.error "Email sending failed: #{e.message}"
      end

      render json: {
        data: {
          id: @chat_message.id,
          message: @chat_message.message,
          sender_type: @chat_message.sender_type,
          sender_name: @chat_message.sender_name,
          created_at: @chat_message.created_at,
          read: @chat_message.read,
        },
      }, status: :created
    else
      render json: {
        errors: @chat_message.errors.full_messages,
      }, status: :unprocessable_entity
    end
  end

  def mark_as_read
    # Mark messages as read based on user type
    if @current_user.id == @campaign.user_id
      # Creator marking donor messages as read
      @campaign.chat_messages.where(sender_type: "donor", read: false).update_all(
        read: true,
        read_at: Time.current,
      )
    else
      # Donor marking creator messages as read
      @campaign.chat_messages.where(sender_type: "creator", read: false).update_all(
        read: true,
        read_at: Time.current,
      )
    end

    render json: { success: true }, status: :ok
  end

  def unread_count
    if @current_user.id == @campaign.user_id
      # Creator checking unread donor messages
      count = @campaign.chat_messages.where(sender_type: "donor", read: false).count
    else
      # Donor checking unread creator messages
      count = @campaign.chat_messages.where(sender_type: "creator", read: false).count
    end

    render json: { unread_count: count }
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def set_chat_message
    @chat_message = @campaign.chat_messages.find(params[:id])
  end

  def chat_message_params
    params.require(:chat_message).permit(:message)
  end
end

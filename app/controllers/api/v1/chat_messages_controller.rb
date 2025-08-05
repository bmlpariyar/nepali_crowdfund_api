class Api::V1::ChatMessagesController < ApplicationController
  before_action :authorized
  before_action :find_campaign

  def index
    conversations = @current_user.all_conversations.where(campaign: @campaign)

    # Or get messages from a specific conversation
    if params[:conversation_id].present?
      conversation = conversations.find(params[:conversation_id])
      messages = conversation.chat_messages.includes(:user).order(:created_at)
    else
      # Get all messages across all conversations for this user in this campaign
      messages = ChatMessage.joins(:conversation)
        .where(conversations: { id: conversations.ids })
        .includes(:user, :conversation)
        .order(:created_at)
    end

    render json: { data: messages.map { |msg| format_message_response(msg) } }
  end

  def create
    conversation = find_or_create_conversation

    @chat_message = conversation.chat_messages.build(chat_message_params)
    @chat_message.user = @current_user
    @chat_message.campaign = @campaign  # Keep if you need campaign-level access
    @chat_message.sender_type = determine_sender_type

    if @chat_message.save
      send_notification(@chat_message, conversation)
      render json: { data: format_message_response(@chat_message) }, status: :created
    else
      render json: { errors: @chat_message.errors.full_messages }, status: :unprocessable_entity
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

  def find_or_create_conversation
    if is_creator?
      donor_id = params[:recipient_id] || params[:donor_id]
      raise ActionController::ParameterMissing, "donor_id required" if donor_id.blank?

      donor = User.find(donor_id)

      Conversation.find_or_create_by(
        campaign: @campaign,
        creator: @current_user,
        donor: donor,
      )
    else
      Conversation.find_or_create_by(
        campaign: @campaign,
        creator: @campaign.user,
        donor: @current_user,
      )
    end
  end

  def send_notification(chat_message, conversation)
    recipient = conversation.other_participant(@current_user)
    send_notification_to_user(recipient, chat_message)
  end

  def send_notification_to_user(recipient, chat_message)
    return if recipient.nil?

    begin
      ChatMailer.new_message_notification(recipient, chat_message).deliver_later
      Rails.logger.info "Email sent successfully to #{recipient.email}"
    rescue => e
      Rails.logger.error "Email sending failed for #{recipient.email}: #{e.message}"
    end
  end

  def is_creator?
    @current_user.id == @campaign.user_id
  end

  def determine_sender_type
    is_creator? ? "creator" : "donor"
  end

  def format_message_response(message)
    {
      id: message.id,
      message: message.message,
      sender_type: message.sender_type,
      sender_name: message.user.full_name,
      conversation_id: message.conversation_id,
      doner_id: message.conversation.donor_id,
      creator_id: message.conversation.creator_id,
      created_at: message.created_at,
      read: message.read,
    }
  end

  def find_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def chat_message_params
    params.require(:chat_message).permit(:message)
  end
end

class ChatMailer < ApplicationMailer
  default from: "leopariyar8@gmail.com"

  def new_message_notification(user, message)
    @user = user
    @message = message
    mail(to: @user.email, subject: "You have a new chat message")
  end
end

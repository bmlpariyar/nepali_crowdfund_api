class AddConversationToChatMessages < ActiveRecord::Migration[7.2]
  def change
    add_reference :chat_messages, :conversation, null: false, foreign_key: true
  end
end

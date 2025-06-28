class CreateChatMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_messages do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false
      t.string :sender_type, null: false # 'creator' or 'donor'
      t.boolean :read, default: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :chat_messages, [:campaign_id, :created_at]
    add_index :chat_messages, [:campaign_id, :read]
    add_index :chat_messages, [:user_id, :created_at]
  end
end

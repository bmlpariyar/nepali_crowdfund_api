class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :donor, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    # Add index for faster lookups
    add_index :conversations, [:campaign_id, :creator_id, :donor_id], unique: true
  end
end

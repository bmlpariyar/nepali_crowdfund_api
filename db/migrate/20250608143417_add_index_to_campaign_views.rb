class AddIndexToCampaignViews < ActiveRecord::Migration[7.2]
  def change
    add_index :campaign_views, [:campaign_id, :user_id], unique: true
  end
end

class CreateCampaignViews < ActiveRecord::Migration[7.2]
  def change
    create_table :campaign_views do |t|
      t.references :user, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true

      t.timestamps
    end
  end
end

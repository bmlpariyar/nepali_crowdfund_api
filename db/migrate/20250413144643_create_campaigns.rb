class CreateCampaigns < ActiveRecord::Migration[7.2]
  def change
    create_table :campaigns do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :story
      t.decimal :funding_goal, null: false
      t.decimal :current_amount, default: 0.0
      t.datetime :deadline
      t.string :status, default: "draft"
      t.string :slug
      t.string :image_url
      t.string :video_url

      t.timestamps
    end
  end
end

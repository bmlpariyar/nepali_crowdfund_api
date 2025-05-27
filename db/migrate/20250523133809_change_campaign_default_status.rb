class ChangeCampaignDefaultStatus < ActiveRecord::Migration[7.2]
  def change
    change_column_default :campaigns, :status, from: "draft", to: "active"
  end
end

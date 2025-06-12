class AddLocationAndAddressToCampaigns < ActiveRecord::Migration[7.2]
  def change
    add_column :campaigns, :address, :string
    add_column :campaigns, :latitude, :float
    add_column :campaigns, :longitude, :float
  end
end

class AddLocationToUserProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :user_profiles, :latitude, :float
    add_column :user_profiles, :longitude, :float
  end
end

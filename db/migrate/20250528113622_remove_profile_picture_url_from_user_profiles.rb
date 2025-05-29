class RemoveProfilePictureUrlFromUserProfiles < ActiveRecord::Migration[7.2]
  def change
    remove_column :user_profiles, :profile_picture_url, :string
  end
end

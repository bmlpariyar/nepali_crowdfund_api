class AddSupportMessageToDonations < ActiveRecord::Migration[7.2]
  def change
    add_column :donations, :support_message, :string
  end
end

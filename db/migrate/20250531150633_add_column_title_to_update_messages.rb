class AddColumnTitleToUpdateMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :update_messages, :title, :string
  end
end

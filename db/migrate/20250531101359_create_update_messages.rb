class CreateUpdateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :update_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.text :message

      t.timestamps
    end
  end
end

class CreateDonations < ActiveRecord::Migration[7.2]
  def change
    create_table :donations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.decimal :amount
      t.string :status, default: "pending"
      t.boolean :is_anonymous, default: false
      t.string :payment_gateway_transaction_id

      t.timestamps
    end
  end
end

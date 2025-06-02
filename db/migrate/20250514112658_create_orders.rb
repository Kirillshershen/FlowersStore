class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :price
      t.string :payment_method
      t.string :delivery_method
      t.string :delivery_address
      t.datetime :ready_date
      t.string :status, null: false, default: ''
      t.text :comment 

      t.timestamps
    end
  end
end

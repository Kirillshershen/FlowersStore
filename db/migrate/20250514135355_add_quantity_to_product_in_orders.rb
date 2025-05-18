class AddQuantityToProductInOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :product_in_orders, :quantity, :integer
  end
end

class AddCustomToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :custom, :boolean, default: false
  end
end

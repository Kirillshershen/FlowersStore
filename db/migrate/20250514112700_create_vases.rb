class CreateVases < ActiveRecord::Migration[8.0]
  def change
    create_table :vases do |t|
      t.string :name
      t.string :size
      t.string :material
      t.decimal :price
      t.decimal :discount
      t.decimal :diameter

      t.timestamps
    end
  end
end

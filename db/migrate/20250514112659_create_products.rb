class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.references :productable, polymorphic: true, null: true
      t.string :product_type

      t.json :metadata

      t.timestamps

      
    end
  end
end

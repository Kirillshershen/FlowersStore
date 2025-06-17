class CreateQuantityPromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :quantity_promotions do |t|
      t.references :promotion, null: false, foreign_key: true
      t.integer :min_quantity, null: false
      t.decimal :discount_value, null: false

      t.timestamps
    end
  end
end

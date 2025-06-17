class CreatePromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :discount_type
      t.decimal :discount_value
      t.boolean :active

      t.timestamps
    end
  end
end

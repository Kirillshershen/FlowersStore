class CreatePromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :discount_type
      t.decimal :discount_value
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active

      t.timestamps
    end
  end
end

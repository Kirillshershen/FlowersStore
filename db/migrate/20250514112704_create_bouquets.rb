class CreateBouquets < ActiveRecord::Migration[8.0]
  def change
    create_table :bouquets do |t|
      t.string :name
      t.references :bouquet_type, null: false, foreign_key: true
      t.references :bouquet_packaging, null: false, foreign_key: true
      t.decimal :price
      t.decimal :discount

      t.timestamps
    end
  end
end

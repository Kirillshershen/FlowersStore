class CreateFlowers < ActiveRecord::Migration[8.0]
  def change
    create_table :flowers do |t|
      t.string :name
      t.references :flower_type, null: false, foreign_key: true
      t.decimal :price
      t.decimal :discount

      t.timestamps
    end
  end
end

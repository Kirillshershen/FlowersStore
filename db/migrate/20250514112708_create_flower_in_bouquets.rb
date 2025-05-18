class CreateFlowerInBouquets < ActiveRecord::Migration[8.0]
  def change
    create_table :flower_in_bouquets do |t|
      t.references :flower, null: false, foreign_key: true
      t.references :bouquet, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end

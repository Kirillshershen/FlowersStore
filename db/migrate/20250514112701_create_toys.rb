class CreateToys < ActiveRecord::Migration[8.0]
  def change
    create_table :toys do |t|
      t.string :name
      t.string :size
      t.string :material
      t.decimal :price
      t.decimal :discount

      t.timestamps
    end
  end
end

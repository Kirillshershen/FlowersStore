class CreatePackagings < ActiveRecord::Migration[6.1]
  def change
    create_table :packagings do |t|
      t.string :name, null: false
      t.string :material
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end

class CreateBouquetPackagings < ActiveRecord::Migration[8.0]
  def change
    create_table :bouquet_packagings do |t|
      t.string :name
      t.decimal :price

      t.timestamps
    end
  end
end

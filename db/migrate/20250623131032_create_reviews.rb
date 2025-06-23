class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.integer :rating, null: false, inclusion: { in: 1..5 }

      t.timestamps
    end
  end
end
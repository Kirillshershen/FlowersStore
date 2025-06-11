class CreateBanners < ActiveRecord::Migration[8.0]
  def change
    create_table :banners do |t|
      t.string :title
      t.string :subtitle
      t.string :link

      t.timestamps
    end
  end
end

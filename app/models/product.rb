class Product < ApplicationRecord
attr_accessor :metadata_json
  has_many :product_in_orders
  has_many :orders, through: :product_in_orders
  has_one_attached :image
has_many :product_promotions
has_many :promotions, through: :product_promotions


  def self.ransackable_attributes(auth_object = nil)
    %w[name metadata product_type]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[image_attachment image_blob orders product_in_orders]
  end

  scope :with_bouquet_type, ->(type) {
    where(product_type: "Букет")
      .where("metadata->>'bouquet_type' = ?", type)
  }

  # Сделаем алиас ransack
  def self.ransackable_scopes(auth_object = nil)
    %i[with_bouquet_type]
  end



end
class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  has_many :product_in_orders
  has_many :orders, through: :product_in_orders
end

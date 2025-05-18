class Order < ApplicationRecord
  belongs_to :user
  has_many :product_in_orders
  has_many :products, through: :product_in_orders
end

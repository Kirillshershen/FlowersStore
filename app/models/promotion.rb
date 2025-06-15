class Promotion < ApplicationRecord
  has_many :product_promotions
  has_many :products, through: :product_promotions


end
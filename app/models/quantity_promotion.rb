class QuantityPromotion < ApplicationRecord
  belongs_to :promotion

  validates :min_quantity, numericality: { greater_than: 0 }
  validates :discount_value, numericality: { greater_than_or_equal_to: 0 }
end

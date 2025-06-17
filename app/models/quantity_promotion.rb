class QuantityPromotion < ApplicationRecord
  belongs_to :promotion

  validates :min_quantity, presence: true, numericality: { greater_than: 0 }
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

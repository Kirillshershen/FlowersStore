class Flower < ApplicationRecord
  belongs_to :flower_type
  has_one :product, as: :productable
end

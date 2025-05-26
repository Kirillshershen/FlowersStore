class Vase < ApplicationRecord
  has_one :product, as: :productable
end
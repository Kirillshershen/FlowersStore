class Toy < ApplicationRecord
  has_one :product, as: :productable
end
class Bouquet < ApplicationRecord
  belongs_to :bouquet_type
  belongs_to :bouquet_packaging
  has_many :flower_in_bouquets
  has_many :flowers, through: :flower_in_bouquets
  has_one :product, as: :productable
end
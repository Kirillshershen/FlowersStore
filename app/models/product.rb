class Product < ApplicationRecord
  attr_accessor :metadata_json

  has_many :product_in_orders
  has_many :orders, through: :product_in_orders
  has_one_attached :image

  has_many :product_promotions
  has_many :promotions, through: :product_promotions

    def current_promotion_info
    active_promo = promotions
      .where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current)
      .first

    return nil unless active_promo

    discount_value = if active_promo.percentage?
      "#{active_promo.discount_value}%"
    else
      # Например, 100 рублей скидка
      "#{active_promo.discount_value} ₽"
    end

    {
      discount_type: active_promo.percentage? ? 'percentage' : 'amount',
      discount_value: active_promo.discount_value,
      display_text: "Скидка: #{discount_value}"
    }
  end

  # Метод, чтобы узнать, есть ли скидка
  def discounted?
    current_promotion_info.present?
  end




  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[name metadata product_type]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[image_attachment image_blob orders product_in_orders promotions]
  end

  scope :with_bouquet_type, ->(type) {
    where(product_type: "Букет")
      .where("metadata->>'bouquet_type' = ?", type)
  }

  scope :with_active_promotions, -> {
    joins(:promotions)
      .where("promotions.starts_at <= ? AND promotions.ends_at >= ?", Time.current, Time.current)
  }

  def self.ransackable_scopes(auth_object = nil)
    %i[with_bouquet_type]
  end
end

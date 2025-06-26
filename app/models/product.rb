class Product < ApplicationRecord
  attr_accessor :metadata_json

  has_many :product_in_orders
  has_many :orders, through: :product_in_orders
  has_one_attached :image

  has_many :product_promotions
  has_many :promotions, through: :product_promotions
after_save :update_related_bouquets_price, if: :saved_change_to_price?

def update_related_bouquets_price
  # Пробегаем по всем продуктам, у которых есть metadata
  Product.all.each do |product|
    next unless product.metadata.is_a?(Hash)

    flowers_data = product.metadata["flowers"]
    packaging_id = product.metadata["packaging"]&.to_s

    # Собираем все product_id цветов из metadata["flowers"]
    flower_ids = flowers_data&.values&.map { |f| f["product_id"].to_s } || []

    # Если текущий продукт (self) используется как цветок или упаковка — обновляем букет
    if flower_ids.include?(id.to_s) || packaging_id == id.to_s
      product.recalculate_price!
    end
  end
end


# в модели Product
def recalculate_price!
  return unless self_is_bouquet?

  flower_total = metadata["flowers"].values.sum do |flower_info|
    flower = Product.find_by(id: flower_info["product_id"])
    next 0 unless flower
    flower.price * flower_info["quantity"].to_i
  end

  packaging_price = 0
  if metadata["packaging"]
    packaging = Product.find_by(id: metadata["packaging"])
    packaging_price = packaging&.price.to_f
  end

  update(price: flower_total + packaging_price)
end

def self_is_bouquet?
  # реализуй свой способ — например, по типу или метаданным
  metadata["flowers"].present?
end

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

  def discounted?
    current_promotion_info.present?
  end
def best_quantity_discount(current_quantity = 1)
  promotions.flat_map(&:quantity_promotions)
            .select { |qp| qp.min_quantity <= current_quantity }
            .max_by(&:discount_value)
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

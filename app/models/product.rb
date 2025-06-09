class Product < ApplicationRecord
attr_accessor :metadata_json
  has_many :product_in_orders
  has_many :orders, through: :product_in_orders
  has_one_attached :image
has_many :product_promotions
has_many :promotions, through: :product_promotions

  after_update :update_bouquets_price_if_flower_price_changed, if: :saved_change_to_price?

  def update_bouquets_price_if_flower_price_changed
    # Проверяем, что это цветок
    return unless ['flower', 'цветок'].include?(product_type.to_s.downcase)

 # или 'Цветок' в зависимости от локализации

    # Перебираем все букеты, где есть этот цветок
    bouquets_with_this_flower = Product.where(product_type: "Букет").select do |bouquet|
      # bouquet.bouquet_flowers возвращает хэш с цветами
      bouquet.bouquet_flowers.any? { |_, flower_data| flower_data['product_id'].to_i == id }
    end

    # Обновляем цену каждого букета, пересчитывая её через calculated_bouquet_price
    bouquets_with_this_flower.each do |bouquet|
      new_price = bouquet.calculated_bouquet_price
      bouquet.update(price: new_price)
    end
  end

  # bouquet_flowers — у тебя есть, возвращает хэш цветов из metadata
  # calculated_bouquet_price — тоже есть
  def self.ransackable_attributes(auth_object = nil)
    %w[name metadata product_type]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[image_attachment image_blob orders product_in_orders]
  end

  scope :with_bouquet_type, ->(type) {
    where(product_type: "Букет")
      .where("metadata->>'bouquet_type' = ?", type)
  }

  # Сделаем алиас ransack
  def self.ransackable_scopes(auth_object = nil)
    %i[with_bouquet_type]
  end
  def active_promotion
  promotions.where(active: true)
            .where('starts_at <= ? AND ends_at >= ?', Time.current, Time.current)
            .order(ends_at: :asc)
            .first
end

def final_price
  promo = active_promotion
  return price unless promo

  case promo.discount_type
  when "percentage"
    price - (price * promo.discount_value / 100.0)
  when "fixed"
    [price - promo.discount_value, 0].max
  else
    price
  end
end
def discounted_price
    # Получаем активные промоции для этого продукта
    active_promos = promotions.where(active: true)
    
    price_after_discount = price.to_f

    active_promos.each do |promo|
      if promo.discount_type == 'percent'
        price_after_discount -= price_after_discount * (promo.discount_value.to_f / 100)
      elsif promo.discount_type == 'fixed'
        price_after_discount -= promo.discount_value.to_f
      end
    end

    # Цена не может быть меньше нуля
    price_after_discount > 0 ? price_after_discount.round(2) : 0
  end
    def bouquet_flowers
    # Возвращает хэш цветов из metadata (или пустой, если нет)
    metadata&.[]('flowers') || {}
  end
  def calculated_bouquet_price
  return price unless bouquet_flowers.present?

  # 1. Считаем цену всех цветов с учётом их скидок
  total_flowers_price = 0.0
  bouquet_flowers.each do |_, flower_data|
    flower = Product.find_by(id: flower_data['product_id'])
    next unless flower

    quantity = flower_data['quantity'].to_i
    unit_price = flower.active_promotion ? flower.final_price : flower.price
    total_flowers_price += unit_price.to_f * quantity
  end

  # 2. Проверяем скидку на сам букет
  bouquet_price = price.to_f
  if active_promotion
    bouquet_price = final_price.to_f
  end

  # 3. Итоговая цена — это сумма цен цветов + разница между ценой букета со скидкой и без неё (если букет со скидкой)
  # Здесь можно трактовать по-разному, например:
  #  - либо заменять цену букета на цену цветов (возможно логичнее)
  #  - либо добавлять скидку букета как отдельную скидку сверху (покажу такой вариант)

  # Рассчитаем скидку на букет
  bouquet_discount = price.to_f - bouquet_price

  # Итог: сумма цветов минус скидка букета
  total_price = total_flowers_price - bouquet_discount
  total_price > 0 ? total_price : 0
end

end
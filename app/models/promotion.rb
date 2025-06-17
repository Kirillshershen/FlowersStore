class Promotion < ApplicationRecord
  has_many :product_promotions, dependent: :destroy
  has_many :products, through: :product_promotions

  has_many :quantity_promotions, dependent: :destroy
  accepts_nested_attributes_for :quantity_promotions, allow_destroy: true

  # Проверка активной количественной скидки
  def quantity_discount_for(quantity)
    return 0 unless discount_type == "quantity" && active?

    quantity_promotions
      .where('min_quantity <= ?', quantity)
      .order(min_quantity: :desc)
      .limit(1)
      .pluck(:discount_value)
      .first || 0
  end

  # Проверка процентной скидки
  def percentage?
    discount_type == 'percentage'
  end

  # Проверка фиксированной (денежной) скидки
  def amount?
    discount_type == 'amount'
  end
end

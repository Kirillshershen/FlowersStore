class Order < ApplicationRecord
  belongs_to :user
  has_many :product_in_orders
  has_many :products, through: :product_in_orders

  # Валидации обязательны только если статус не draft
  validates :delivery_method, presence: true, unless: -> { status == 'draft' }
  validates :ready_date, presence: true, unless: -> { status == 'draft' }

  # Кастомная валидация, тоже только если не draft
  validate :ready_date_at_least_one_hour_from_now, unless: -> { status == 'draft' }

  def ready_date_at_least_one_hour_from_now
    return if ready_date.blank?

    if ready_date < 1.hour.from_now
      errors.add(:ready_date, "должна быть как минимум через 1 час от текущего времени")
    end 
  end
end

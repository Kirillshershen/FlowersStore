class Order < ApplicationRecord
  belongs_to :user
  has_many :product_in_orders
  has_many :products, through: :product_in_orders
 after_update :create_status_notification, if: :saved_change_to_status?
  STATUS_OPTIONS = %w[подтвержден готов завершен отменен].freeze

  validates :delivery_method, presence: true, unless: -> { status == 'draft' }
  validates :ready_date, presence: true, unless: -> { status == 'draft' }
  validate :ready_date_at_least_one_hour_from_now, unless: -> { status == 'draft' }

  def ready_date_at_least_one_hour_from_now
    return if ready_date.blank?
    if ready_date < 1.hour.from_now
      errors.add(:ready_date, "должна быть как минимум через 1 час от текущего времени")
    end 
  end

 def create_status_notification
    case status
    when 'готов'
    user.notifications.create(order: self, message: "Ваш заказ ##{id} завершен.", read: false)
    when 'оформлен'
    user.notifications.create(order: self, message: "Ваш заказ ##{id} завершен.", read: false)
    when 'завершен'
    user.notifications.create(order: self, message: "Ваш заказ ##{id} завершен.", read: false)
    end
  end

end

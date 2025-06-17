# app/controllers/admin/statistics_controller.rb
class Admin::StatisticsController < ApplicationController
  before_action :authenticate_admin! # Если у тебя есть авторизация для админов

  def sales
    @completed_orders = Order.includes(:product_in_orders).where(status: 'завершен')

    @sales_data = @completed_orders.map do |order|
      {
        order: order,
        items: order.product_in_orders.map do |item|
          {
            quantity: item.quantity,
            snapshot: item.metadata || {}
          }
        end
      }
    end
  end
end

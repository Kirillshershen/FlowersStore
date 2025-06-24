class Admin::StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def sales
  @completed_orders = Order.where(status: 'завершен').includes(product_in_orders: :product)

  # Общая сумма всех заказов
  @total_revenue = @completed_orders.sum(&:price)

  # Подсчёт проданных цветов
  flower_sales = Hash.new(0)
  @top_bouquets_list = []

  @completed_orders.each do |order|
    order.product_in_orders.each do |item|
      product = item.product
      next unless product&.product_type == "Букет"

      flowers_data = item.metadata.dig("metadata", "flowers") || {}
      flowers_data.values.select { |f| f["product_id"].present? }.each do |flower_info|
        flower_id = flower_info["product_id"].to_i
        quantity = flower_info["quantity"].to_i
        flower_sales[flower_id] += quantity * item.quantity
      end

      # Сборка топа букетов
      bouquet_quantity = item.quantity
      @top_bouquets_list << {
        id: product.id,
        name: product.name,
        price: product.price,
        quantity_sold: bouquet_quantity
      }
    end
  end

  top_flower_ids = flower_sales.keys
  flowers = Product.find(top_flower_ids).index_by(&:id)

  @top_flowers = flower_sales.map do |flower_id, total_quantity|
    flower = flowers[flower_id]
    {
      name: flower&.name || "Неизвестный цветок (ID: #{flower_id})",
      quantity_sold: total_quantity
    }
  end.sort_by { |f| -f[:quantity_sold] }

  # ТОП букетов
  @top_bouquets_list = @top_bouquets_list.group_by { |b| b[:id] }.map do |bouquet_id, items|
    first_bouquet = items.first
    {
      id: bouquet_id,
      name: first_bouquet[:name],
      price: first_bouquet[:price],
      quantity_sold: items.sum { |i| i[:quantity_sold] }
    }
  end.sort_by { |b| -b[:quantity_sold] }
end

  private

  def require_admin
    redirect_to root_path, alert: "Доступ запрещён" unless current_user&.admin?
  end
end
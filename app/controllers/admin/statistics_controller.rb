class Admin::StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def sales
    @completed_orders = Order.where(status: 'выполнен').includes(product_in_orders: :product)

    # Общая выручка
    @total_revenue = @completed_orders.sum(&:price)

    # Подсчёт цветов
    flower_sales = Hash.new(0)
    @completed_orders.each do |order|
      order.product_in_orders.each do |item|
        product = item.product
        next unless product&.product_type == "Букет"

        flowers_data = item.metadata.dig("metadata", "flowers") || {}
        flowers_data.values.each do |flower_info|
          flower_id = flower_info["product_id"].to_i
          quantity = flower_info["quantity"].to_i
          next if flower_id.zero? || quantity.zero?

          flower_sales[flower_id] += quantity * item.quantity
        end
      end
    end

    top_flower_ids = flower_sales.keys
    @top_flowers = Product.where(id: top_flower_ids).index_by(&:id)
    @top_flowers_list = flower_sales.map do |flower_id, total_quantity|
      {
        name: @top_flowers[flower_id]&.name || "Неизвестный цветок (ID: #{flower_id})",
        quantity_sold: total_quantity
      }
    end.sort_by { |f| -f[:quantity_sold] }

    # Топ букетов
    bouquet_sales = Hash.new(0)
    @completed_orders.each do |order|
      order.product_in_orders.each do |item|
        product = item.product
        next unless product&.product_type == "Букет"
        bouquet_sales[product.id] += item.quantity
      end
    end

    @top_bouquets = Product.where(id: bouquet_sales.keys).index_by(&:id)
    @top_bouquets_list = bouquet_sales.map do |bouquet_id, total_quantity|
      {
        name: @top_bouquets[bouquet_id]&.name || "Неизвестный букет (ID: #{bouquet_id})",
        quantity_sold: total_quantity,
        price: @top_bouquets[bouquet_id]&.price || 0
      }
    end.sort_by { |b| -b[:quantity_sold] }
  end

  private

  def require_admin
    redirect_to root_path, alert: "Доступ запрещён" unless current_user&.admin?
  end
end
class Admin::StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def sales
    @completed_orders = Order.where(status: 'завершен').includes(:product_in_orders)

    # Общая сумма всех заказов
    @total_revenue = @completed_orders.sum(&:price)

    # Количество завершённых заказов
    @total_orders_count = @completed_orders.count

    # Подсчёт проданных цветов
    flower_sales = Hash.new(0)
    bouquet_sales = Hash.new(0)

    @top_flowers_list = []
    @top_bouquets_list = []

    @completed_orders.each do |order|
      order.product_in_orders.each do |item|
        product = item.product
        next unless product

        if product.product_type == "Букет"
          # Букеты
          bouquet_sales[product.id] += item.quantity
          @top_bouquets_list << {
            id: product.id,
            name: product.name,
            price: product.price,
            quantity_sold: item.quantity
          }
        else
          # Цвета в букетах
          flowers_data = item.metadata.dig("metadata", "flowers") || {}
          next unless flowers_data.is_a?(Hash)

          flowers_data.values.select { |f| f["product_id"].present? }.each do |flower_info|
            flower_id = flower_info["product_id"].to_i
            quantity = flower_info["quantity"].to_i
            next if flower_id.zero? || quantity.zero?

            flower_sales[flower_id] += quantity * item.quantity
          end
        end
      end
    end

    # ТОП Цветов
    top_flower_ids = flower_sales.keys
    flowers = Product.find(top_flower_ids).index_by(&:id)
    @top_flowers = flower_sales.map do |flower_id, total_quantity|
      flower = flowers[flower_id]
      {
        name: flower&.name || "Неизвестный цветок (ID: #{flower_id})",
        quantity_sold: total_quantity,
        revenue: (flower&.price.to_f * total_quantity).round(2)
      }
    end.sort_by { |f| -f[:quantity_sold] }

    # ТОП Букетов
    top_bouquet_ids = bouquet_sales.keys
    bouquets = Product.find(top_bouquet_ids).index_by(&:id)

    @top_bouquets_list = bouquet_sales.map do |bouquet_id, total_quantity|
      bouquet = bouquets[bouquet_id]
      {
        name: bouquet&.name || "Неизвестный букет (ID: #{bouquet_id})",
        quantity_sold: total_quantity,
        revenue: (bouquet&.price.to_f * total_quantity).round(2)
      }
    end.sort_by { |b| -b[:quantity_sold] }

    # Общий доход по цветам
    @total_flower_revenue = @top_flowers.sum { |f| f[:revenue] }

    # Общий доход по букетам
    @total_bouquet_revenue = @top_bouquets_list.sum { |b| b[:revenue] }

    # Средний чек
    @average_order_value = @total_orders_count > 0 ? (@total_revenue / @total_orders_count).round(2) : 0
    
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Доступ запрещён" unless current_user.admin?
  end
end
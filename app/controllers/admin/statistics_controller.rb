class Admin::StatisticsController < ApplicationController


def sales
  @completed_orders = Order.includes(product_in_orders: :product).where(status: 'завершен')

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

  @total_revenue = @completed_orders.sum(&:price)

  flower_sales = Hash.new(0)

  @completed_orders.each do |order|
    order.product_in_orders.each do |item|
      product = item.product
      next unless product.product_type == "Букет"

      # Здесь берем цветы из item.metadata['metadata']['flowers']
      flowers = item.metadata.dig("metadata", "flowers") || {}
      next if flowers.blank?

      flowers.each do |_, flower_data|
        flower_id = flower_data["product_id"].to_i
        qty = flower_data["quantity"].to_i
        flower_sales[flower_id] += qty * item.quantity
      end
    end
  end

  @top_flowers = Product.where(id: flower_sales.keys).map do |flower|
    {
      flower: flower,
      quantity_sold: flower_sales[flower.id] || 0
    }
  end.sort_by { |h| -h[:quantity_sold] }
end


  private

  def check_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end

class OrdersController < ApplicationController
  before_action :authenticate_user!

def show
  @order = current_user.orders.find_or_create_by(status: 'draft')
  @product_in_orders = @order.product_in_orders.includes(:product)

  @discounts_by_order_item = {}
  @max_possible_discounts = {}

  @product_in_orders.each do |item|
    product = item.product
    quantity = item.quantity

    best_discount_percent = 0
    max_possible_discount = 0

    # Все активные промоакции
    promotions = product.promotions.select(&:active?)

    promotions.each do |promo|
      case promo.discount_type
      when "fixed"
        fixed_discount = promo.discount_value.to_f
        # Фиксированная скидка — конвертируем в процентную для отображения
        percent_fixed = (fixed_discount / product.price) * 100.0
        max_possible_discount = [max_possible_discount, percent_fixed].max

        if quantity >= 1
          best_discount_percent = [best_discount_percent, percent_fixed].max
        end

      when "percent"
        percent_discount = promo.discount_value.to_f
        max_possible_discount = [max_possible_discount, percent_discount].max

        if quantity >= 1
          best_discount_percent = [best_discount_percent, percent_discount].max
        end

      when "quantity"
        promo.quantity_promotions.each do |qp|
          next unless qp.min_quantity.present? && qp.discount_value.present?

          discount_percent = qp.discount_value.to_f
          max_possible_discount = [max_possible_discount, discount_percent].max

          if quantity >= qp.min_quantity
            best_discount_percent = [best_discount_percent, discount_percent].max
          end
        end
      end
    end

    @discounts_by_order_item[item.id] = best_discount_percent.round(2)
    @max_possible_discounts[item.id] = max_possible_discount.round(2)
  end
end



def add_item
  @order = current_user.orders.find_or_create_by(status: 'draft')
  product = Product.find(params[:product_id])
  quantity = params[:quantity].to_i
  quantity = 1 if quantity <= 0  # защита от нуля и отрицательных значений

  item = @order.product_in_orders.find_or_initialize_by(product: product)
  item.quantity = (item.quantity || 0) + quantity
  item.save
 flash[:notice] = "Товар добавлен в корзину"
  redirect_to catalog_product_path(product)
end


   def decrease_item
    @order = current_user.orders.find_or_create_by(status: 'draft')
    product = Product.find(params[:product_id])
    @item = @order.product_in_orders.find_by(product: product)

    if @item
      if @item.quantity > 1
        @item.quantity -= 1
        @item.save
      else
        @item.destroy
      end
    end

    redirect_to order_path
  end
  
   def increase_item
    @order = current_user.orders.find_or_create_by(status: 'draft')
    product = Product.find(params[:product_id])
    @item = @order.product_in_orders.find_or_initialize_by(product: product)
    @item.quantity = (@item.quantity || 0) + 1
    @item.save
      redirect_to order_path
   end
def index
  @orders = current_user.orders.where.not(status: 'draft')

  status_priority = {
    "готов" => 0,
    "подтвержден" => 1,
    "завершен" => 2,
    "отменен" => 3
  }

  @orders = @orders.sort_by do |order|
    [status_priority[order.status] || 99, order.ready_date || Time.zone.now]
  end
end




def remove_item
  @order = current_user.orders.find_or_create_by(status: 'draft')
  item = @order.product_in_orders.find_by(product_id: params[:product_id])
  item&.destroy
  redirect_to order_path, notice: 'Товар удалён из заказа.'
end

def details
  @order = current_user.orders.find(params[:id])
end


  
def confirm
  @order = current_user.orders.find_by(status: 'draft')
  if @order&.product_in_orders&.any?
    update_params = params.require(:order).permit(:delivery_method, :delivery_address, :ready_date, :comment)

    # Сохраняем снимки продуктов
    @order.product_in_orders.each do |item|
      product = item.product
      product_snapshot = {
        name: product.name,
        price: product.price,
        product_type: product.product_type,
        rating: product.try(:rating),
        metadata: product.metadata,
        image_url: product.image.attached? ? url_for(product.image) : nil
      }
      item.update(metadata: product_snapshot)
    end

    total_price = @order.product_in_orders.sum { |item| item.product.price * item.quantity }

    @order.update(
      status: 'подтвержден',
      ready_date: update_params[:ready_date].presence || Time.current,
      delivery_method: update_params[:delivery_method],
      delivery_address: update_params[:delivery_address],
      comment: update_params[:comment],
      price: total_price
    )

    redirect_to root_path, notice: 'Заказ оформлен!'
  else
    redirect_to order_path, alert: 'Нельзя оформить пустой заказ.'
  end
end



  def update_quantity
  @order = current_user.orders.find_or_create_by(status: 'draft')
  product = Product.find(params[:product_id])
  item = @order.product_in_orders.find_by(product: product)

  new_quantity = params[:quantity].to_i
  if item && new_quantity >= 1
    item.update(quantity: new_quantity)
  end

  respond_to do |format|
    format.js  
    format.html { redirect_to order_path }
  end
end

def cancel
  @order = Order.find(params[:id])

  if @order.status != 'отменен'
    @order.update(status: 'отменен')
    flash[:notice] = "Заказ №#{@order.id} успешно отменён."
  else
    flash[:alert] = "Заказ уже отменён."
  end

  redirect_to orders_path
end

end

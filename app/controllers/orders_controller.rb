class OrdersController < ApplicationController
  before_action :authenticate_user!

def show
  @order = current_user.orders.find_or_create_by(status: 'draft')
  @product_in_orders = @order.product_in_orders.includes(product: :promotions) # заранее загрузим связи

  @promotions_by_product_id = {}

  @product_in_orders.each do |item|
    product = item.product
    # Загружаем промоакции с quantity_promotions для каждого продукта
    promotions = product.promotions.includes(:quantity_promotions)

    # Формируем массив quantity_promotions, чтобы потом в виде можно легко их перебрать
    @promotions_by_product_id[product.id] = promotions.flat_map do |promo|
      promo.quantity_promotions.map do |qp|
        {
          quantity: qp.min_quantity,            # или qp.quantity, если в модели так называется
          discount_type: promo.discount_type,  # если нужно знать тип скидки (percent/fixed)
          discount_value: qp.discount_value.to_f,
          promotion_id: promo.id
        }
      end
    end
  end
end

  def add_item
    @order = current_user.orders.find_or_create_by(status: 'draft')
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity <= 0

    item = @order.product_in_orders.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + quantity
    item.save

    redirect_to catalog_product_path(product), notice: "Добавлено в заказ"
  end


  def remove_item
    @order = current_user.orders.find_or_create_by(status: 'draft')
    item = @order.product_in_orders.find_by(product_id: params[:product_id])
    item&.destroy

    redirect_to order_path, notice: 'Товар удалён из заказа.'
  end

  def confirm
    @order = current_user.orders.find_by(status: 'draft')
    if @order&.product_in_orders&.any?
      update_params = params.require(:order).permit(:delivery_method, :delivery_address, :ready_date, :comment)

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

  def details
    @order = current_user.orders.find(params[:id])
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

  private

  # Вспомогательный метод для подсчёта цены с учётом скидок (если нужен где-то отдельно)
  def discounted_price
    promotions = product.promotions.includes(:quantity_promotions)
    quantity_discounts = promotions.flat_map(&:quantity_promotions)

    applicable = quantity_discounts.select { |d| quantity >= d.min_quantity }.max_by(&:min_quantity)
    base_price = product.price

    if applicable
      if applicable.discount_type == 'percent'
        base_price * (1 - applicable.discount_value.to_f / 100)
      elsif applicable.discount_type == 'fixed'
        base_price - applicable.discount_value
      else
        base_price
      end
    else
      base_price
    end
  end

  def total_price
    discounted_price * quantity
  end

  # orders_controller.rb
def update_quantity
  product = Product.find(params[:product_id])
  item = current_user.product_in_orders.find_by(product: product)

  if item && params[:quantity].to_i >= 1
    item.update(quantity: params[:quantity].to_i)

    # Перерасчет скидки
    quantity_promos = @promotions_by_product_id&.dig(product.id) || Promotion.for_product(product.id)
    applicable_promo = quantity_promos.select { |promo| promo[:quantity] <= item.quantity }.max_by { |promo| promo[:quantity] }

    if applicable_promo
      if applicable_promo[:discount_type] == "percent"
        discounted_price = product.price * (1 - applicable_promo[:discount_value].to_f / 100)
      elsif applicable_promo[:discount_type] == "fixed"
        discounted_price = product.price - applicable_promo[:discount_value]
      else
        discounted_price = product.price
      end
    else
      discounted_price = product.price
    end

    item_total = discounted_price * item.quantity
    total_price = current_user.product_in_orders.includes(:product).sum do |i|
      i_qty = i.quantity
      promos = Promotion.for_product(i.product.id)
      promo = promos.select { |p| p[:quantity] <= i_qty }.max_by { |p| p[:quantity] }

      if promo
        p_price = if promo[:discount_type] == "percent"
          i.product.price * (1 - promo[:discount_value].to_f / 100)
        elsif promo[:discount_type] == "fixed"
          i.product.price - promo[:discount_value]
        else
          i.product.price
        end
      else
        p_price = i.product.price
      end

      p_price * i_qty
    end

    render json: {
      success: true,
      new_quantity: item.quantity,
      item_total: ActionController::Base.helpers.number_to_currency(item_total, unit: "BYN "),
      total_price: ActionController::Base.helpers.number_to_currency(total_price, unit: "BYN "),
      item_id: item.id
    }
  else
    render json: { success: false }, status: :unprocessable_entity
  end
end

private

def order_params
  params.require(:order).permit(:delivery_method, :delivery_address, :ready_date, :comment)
end
end

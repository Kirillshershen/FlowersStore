class OrdersController < ApplicationController
  before_action :authenticate_user!


def show
  @order = current_user.orders.find_or_create_by(status: 'draft')
  @product_in_orders = @order.product_in_orders.includes(:product)
end

  def add_item
    @order = current_user.orders.find_or_create_by(status: 'draft')
    product = Product.find(params[:product_id])
    item = @order.product_in_orders.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + 1
    item.save

  end
  
  def index
    @orders = current_user.orders.where(status: 'confirmed')
  end

  def remove_item
    @order = current_user.orders.find_or_create_by(status: 'draft')
    item = @order.product_in_orders.find_by(product_id: params[:product_id])
    item&.destroy
    redirect_to order_path
  end

  def confirm
    @order = current_user.orders.find_by(status: 'draft')
    if @order&.product_in_orders&.any?
      @order.update(status: 'confirmed', ready_date: Time.current)
      redirect_to root_path, notice: 'Заказ оформлен!'
    else
      redirect_to order_path, alert: 'Нельзя оформить пустой заказ.'
    end
  end
end

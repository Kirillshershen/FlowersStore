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

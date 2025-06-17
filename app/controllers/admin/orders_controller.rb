class Admin::OrdersController < ApplicationController
    before_action :authenticate_user!        
  before_action :check_admin!
  STATUS_OPTIONS = %w[подтвержден готов завершен отменен] 

  def index
    @status_filter = params[:status]

    @orders = if @status_filter.present? && STATUS_OPTIONS.include?(@status_filter)
                Order.where(status: @status_filter)
              else
                Order.all
              end
  end
  def show
    @order = Order.find(params[:id])
  end


  def update_status
    @order = Order.find(params[:id])

    if STATUS_OPTIONS.include?(params[:status])
      @order.update(status: params[:status])
      flash[:notice] = "Статус заказа успешно обновлен."
    else
      flash[:alert] = "Недопустимый статус."
    end

    redirect_to admin_order_path(@order)
  end
    private

  def check_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end

class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin!
  STATUS_OPTIONS = %w[подтвержден готов завершен отменен].freeze


def index
  @status_filter = params[:status]
  @date_filter = params[:delivery_date]

  @orders = Order.all

  if @status_filter.present? && Order::STATUS_OPTIONS.include?(@status_filter)
    @orders = @orders.where(status: @status_filter)
  end

  if @date_filter.present?
    parsed_date = Date.parse(@date_filter)
    @orders = @orders.where("ready_date >= ? AND ready_date <= ?", parsed_date.beginning_of_day, parsed_date.end_of_day)
  end

  @orders = @orders.order(created_at: :desc)
end

  def show
    @order = Order.find(params[:id])
  end

  def update_status
    @order = Order.find(params[:id])

    if STATUS_OPTIONS.include?(params[:status])
      @order.update!(status: params[:status])
      flash[:notice] = "Статус обновлен"
    else
      flash[:alert] = "Недопустимый статус"
    end

    redirect_to admin_order_path(@order)
  end

  private

  def check_admin!
    redirect_to root_path, alert: 'Доступ запрещён' unless current_user&.admin?
  end
end
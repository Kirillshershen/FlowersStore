class Admin::OrdersController < ApplicationController


  def index
    @orders = Order.order(created_at: :desc).all
  end

  def show
    @order = Order.find(params[:id])
  end
end

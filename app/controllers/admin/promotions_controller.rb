class Admin::PromotionsController < ApplicationController
  before_action :set_promotion, only: [:edit, :update, :destroy]
  before_action :authenticate_user! # если используется Devise

  def index
    @promotions = Promotion.all
  end

 def new
  @promotion = Promotion.new
  @promotion.quantity_promotions.build
end

def create
  @promotion = Promotion.new(promotion_params)
  if @promotion.save
    redirect_to admin_promotions_path, notice: "Акция создана"
  else
    render :new
  end
end

  def edit; end

def update
  if @promotion.update(promotion_params)
    redirect_to admin_promotions_path, notice: "Акция обновлена"
  else
    render :edit
  end
end

  def destroy
    @promotion.destroy
    redirect_to admin_promotions_path, notice: 'Акция удалена'
  end

  private

  def set_promotion
    @promotion = Promotion.find(params[:id])
  end
  
def promotion_params
  params.require(:promotion).permit(
    :name,
    :discount_type,
    :discount_value,
    :starts_at,
    :ends_at,
    :active,
    :image,
    product_ids: [],
    quantity_promotions_attributes: [:id, :min_quantity, :discount_value, :_destroy]
  )
end


end

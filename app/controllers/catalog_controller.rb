class CatalogController < ApplicationController
  def index

    if params[:type].present?
      @products = Product.where(productable_type: params[:type])
    else
      @products = Product.all
    end


    if params[:query].present?
      @products = @products.where("name LIKE ?", "%#{params[:query]}%")
    end
  end

  def show
    @product = Product.find(params[:id])
    @specific = @product.productable

    if @specific.is_a?(Bouquet)
      @flowers_in_bouquet = @specific.flower_in_bouquets.includes(:flower)
    end
  end
end

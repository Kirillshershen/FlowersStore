class Admin::ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def edit
    @product.metadata_json = @product.metadata.to_json
  end
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: "Продукт успешно создан"
    else
      render :new
    end
  end




 def update
  if params[:product][:metadata_json].present?
    begin
      parsed_metadata = JSON.parse(params[:product][:metadata_json])
      params[:product][:metadata] = parsed_metadata
    rescue JSON::ParserError
      @product.errors.add(:metadata, "невалидный JSON")
      render :edit and return
    end
  end

  params[:product].delete(:metadata_json)

  if @product.update(product_params)
    redirect_to admin_products_path, notice: "Продукт обновлен"
  else
    render :edit
  end
end



  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_products_path, notice: "Продукт удалён"
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

def product_params
  params.require(:product).permit(:name, :price, :product_type, :image, metadata: {})
end

end

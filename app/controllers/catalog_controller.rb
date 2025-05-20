class CatalogController < ApplicationController
def index
  @products = Product.all

  @products = filter_by_type_or_tab(params[:type], params[:bouquet_type], params[:tab], @products)

  if params[:query].present?
    @products = @products.where("name LIKE ?", "%#{params[:query]}%")
  end

  @products = @products.order(:name)
end

  def show
    @product = Product.find(params[:id])
    @specific = @product.productable

    if @specific.is_a?(Bouquet)
      @flowers_in_bouquet = @specific.flower_in_bouquets.includes(:flower)
    end
  end

  def product_params
    params.require(:product).permit(:name, :price, :description, :product_type_id, :image)
  end

private

def filter_by_type_or_tab(type, bouquet_type, tab, products)
  if type.present? && type != "Bouquet"
    products = Product.where(productable_type: type)
  elsif type == "Bouquet"
    if bouquet_type.present?
      bouquet_ids = Bouquet.joins(:bouquet_type)
                           .where(bouquet_types: { name: bouquet_type.capitalize })
                           .pluck(:id)
      products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
    else
      products = Product.where(productable_type: "Bouquet")
    end
  end

  if tab.present?
    case tab
    when "rose_bouquets"
      bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Роза" }).pluck(:id)
      products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
    when "wedding_bouquets"
      bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Свадебный" }).pluck(:id)
      products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
    when "gift_bouquets"
      bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Подарочный" }).pluck(:id)
      products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
    when "round_bouquets"
      bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Круглый" }).pluck(:id)
      products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
    when "single_flowers", "flowers"
      products = Product.where(productable_type: "Flower")
    when "toys"
      products = Product.where(productable_type: "Toy")
    when "vases"
      products = Product.where(productable_type: "Vase")
    when "all_bouquets"
      products = Product.where(productable_type: "Bouquet")
    end
  end

  products
end
end
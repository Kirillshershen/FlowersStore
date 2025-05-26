class CatalogController < ApplicationController
def index
  @q = Product.ransack(params[:q])
  Rails.logger.debug("FILTER PARAMS: #{params[:q]}")

  @products = @q.result(distinct: true)
                .includes(image_attachment: :blob)
                .order(Arel.sql("metadata->>'bouquet_type'"))

  # Фильтрация по типу букета
  if params.dig(:q, :metadata_bouquet_type_eq).present?
    @products = @products.with_bouquet_type(params[:q][:metadata_bouquet_type_eq])
  end

  # Фильтрация по типу растения
  if params.dig(:q, :metadata_plant_type_eq).present?
    @products = @products.where("metadata->>'plant_type' = ?", params[:q][:metadata_plant_type_eq])
  end


  @products = @products.order(:name)

  @bouquet_types = Product
                    .where(product_type: 'bouquet')
                    .pluck(Arel.sql("DISTINCT metadata->>'bouquet_type'"))
                    .compact
                    .map(&:strip)
                    .sort_by(&:downcase)

  respond_to do |format|
    format.html
    format.json { render json: @products }
  end
end






  def show
  @product = Product.find(params[:id])
  end


    def product_params
      params.require(:product).permit(:name, :price, :product_type, :metadata, :description, :image)
    end






end

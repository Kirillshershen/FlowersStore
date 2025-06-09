class CatalogController < ApplicationController
def index
  @q = Product.ransack(params[:q])
  Rails.logger.debug("ПАРАМЕТРЫ ФИЛЬТРА: #{params[:q]}")

  @products = @q.result(distinct: true)
                .includes(:promotions, image_attachment: :blob)

  # Исключаем пользовательские букеты (custom: true)
  @products = @products.where("products.metadata->>'custom' IS NULL OR products.metadata->>'custom' = 'false'")

  # Фильтрация по типу букета
  if params.dig(:q, :metadata_bouquet_type_eq).present?
    @products = @products.where("products.metadata->>'bouquet_type' = ?", params[:q][:metadata_bouquet_type_eq])
  end

  # Фильтрация по типу растения
  if params.dig(:q, :metadata_plant_type_eq).present?
    @products = @products.where("products.metadata->>'plant_type' = ?", params[:q][:metadata_plant_type_eq])
  end

  # Фильтрация по минимальной цене
  if params[:min_price].present?
    @products = @products.where('products.price >= ?', params[:min_price])
  end

  # Фильтрация по максимальной цене
  if params[:max_price].present?
    @products = @products.where('products.price <= ?', params[:max_price])
  end

  # Фильтрация товаров со скидкой
  if params.dig(:q, :discounted_eq) == 'true'
    # Присоединяем только активные акции и убираем дубликаты
    @products = @products.joins(:promotions).where('promotions.active = ?', true).distinct
  end

  # Сортировка товаров
  case params[:sort]
  when 'newest'
    @products = @products.order(created_at: :desc)
  when 'oldest'
    @products = @products.order(created_at: :asc)
  when 'name_asc'
    @products = @products.order(name: :asc)
  when 'name_desc'
    @products = @products.order(name: :desc)
  when 'price_asc'
    @products = @products.order(price: :asc)
  when 'price_desc'
    @products = @products.order(price: :desc)
  else
    @products = @products.order(:name)
  end

  @products = @products.page(params[:page]).per(16)

  @bouquet_types = Product
                    .where(product_type: 'Букет')
                    .pluck(Arel.sql("DISTINCT products.metadata->>'bouquet_type'"))
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

    @bouquet_types = Product
                      .where(product_type: 'Букет')
                      .pluck(Arel.sql("DISTINCT metadata->>'bouquet_type'"))
                      .compact
                      .map(&:strip)
                      .sort_by(&:downcase)

    @similar_products = Product
                          .where.not(id: @product.id)
                          .where(product_type: @product.product_type)

    # Если продукт — букет, фильтруем похожие по типу букета
    if @product.product_type == 'Букет' && @product.metadata["bouquet_type"].present?
      @similar_products = @similar_products.where("metadata->>'bouquet_type' = ?", @product.metadata["bouquet_type"])
    end

    @similar_products = @similar_products.limit(10)
  end

  private

  def product_params
    params.require(:product).permit(:name, :price, :product_type, :metadata, :description, :image)
  end
end

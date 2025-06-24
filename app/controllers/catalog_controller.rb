class CatalogController < ApplicationController
def index
  @q = Product.ransack(params[:q])
  Rails.logger.debug("ПАРАМЕТРЫ ФИЛЬТРА: #{params[:q]}")

  @products = @q.result(distinct: true)
                .includes(promotions: :quantity_promotions, image_attachment: :blob)

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

  # Фильтр по минимальной цене
  if params[:min_price].present?
    @products = @products.where('products.price >= ?', params[:min_price])
  end

  # Фильтр по максимальной цене
  if params[:max_price].present?
    @products = @products.where('products.price <= ?', params[:max_price])
  end

  # Сборка данных о скидках
  @discounts_by_product = {}

  @products.each do |product|
    best_fixed = 0
    best_percent = 0
    max_possible_discount = 0
    quantity_promos = []

    product.promotions.select(&:active?).each do |promo|
      case promo.discount_type
      when 'fixed'
        best_fixed = [best_fixed, promo.discount_value.to_f].max
      when 'percent'
        best_percent = [best_percent, promo.discount_value.to_f].max
      when 'quantity'
        promo.quantity_promotions.each do |qp|
          discount_value = qp.discount_value.to_f
          max_possible_discount = [max_possible_discount, discount_value].max
          quantity_promos << {
            min_quantity: qp.min_quantity,
            discount_value: discount_value
          }
        end
      end
    end

    total_base_discount = best_fixed + (best_percent / 100.0 * product.price)
    final_price = [product.price - total_base_discount, 0.0].max

    # Сохраняем все скидки по количеству для вывода
    @discounts_by_product[product.id] = {
      fixed: best_fixed,
      percent: best_percent,
      max_possible: max_possible_discount,
      final_price: final_price,
      quantity_promos: quantity_promos
    }
  end

  # Сортировка
  case params[:sort]
  when 'newest' then @products = @products.order(created_at: :desc)
  when 'oldest' then @products = @products.order(created_at: :asc)
  when 'name_asc' then @products = @products.order(name: :asc)
  when 'name_desc' then @products = @products.order(name: :desc)
  when 'price_asc' then @products = @products.order(price: :asc)
  when 'price_desc' then @products = @products.order(price: :desc)
  else @products = @products.order(:name)
  end

  @products = @products.page(params[:page]).per(16)

  # Для фильтров
  @bouquet_types = Product
                    .where(product_type: 'Букет')
                    .pluck(Arel.sql("DISTINCT products.metadata->>'bouquet_type'"))
                    .compact.map(&:strip).sort_by(&:downcase)
end
def show
  @product = Product.find(params[:id])

  # Получаем активные акции (через SQL, чтобы сохранить includes)
  @promotions = @product.promotions.where(active: true).includes(:quantity_promotions)

  # Подготавливаем данные для JS
  @quantity_promotions_for_js = @promotions.flat_map do |promo|
    promo.quantity_promotions.map do |qp|
      {
        min_quantity: qp.min_quantity,
        discount_value: qp.discount_value.to_f,
        promotion_id: qp.promotion_id
      }
    end
  end

  @quantity_discounts = @promotions.flat_map(&:quantity_promotions) || []

  @bouquet_types = Product
                    .where(product_type: 'Букет')
                    .pluck(Arel.sql("DISTINCT metadata->>'bouquet_type'"))
                    .compact.map(&:strip).sort_by(&:downcase)

  @quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1

  # Похожие товары
  @similar_products = Product
                       .where.not(id: @product.id)
                       .where(product_type: @product.product_type)

  if @product.product_type == 'Букет' && @product.metadata["bouquet_type"].present?
    @similar_products = @similar_products.where("metadata->>'bouquet_type' = ?", @product.metadata["bouquet_type"])
  end

  @similar_products = @similar_products.limit(10)
end
  private

  def product_params
    params.require(:product).permit(:name, :price, :product_type, :description , :metadata, :description, :image)
  end
end
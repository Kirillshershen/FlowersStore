class CatalogController < ApplicationController
  def index
    @products = Product.all

    if params[:type].present? && params[:type] != "Bouquet"
      # Если выбран конкретный тип, отличный от Bouquet, фильтруем сразу по нему
      @products = Product.where(productable_type: params[:type])
    elsif params[:type] == "Bouquet"
      # Фильтруем букеты по типу букета, если параметр передан
      if params[:bouquet_type].present?
        bouquet_ids = Bouquet.joins(:bouquet_type)
                             .where(bouquet_types: { name: params[:bouquet_type].capitalize })
                             .pluck(:id)
        @products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
      else
        # Просто все букеты без фильтра по типу букета
        @products = Product.where(productable_type: "Bouquet")
      end
    end

    # Фильтрация по tab (сохраняем логику, но она теперь может переопределять @products)
    if params[:tab].present?
      case params[:tab]
      when "rose_bouquets"
        bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Роза" }).pluck(:id)
        @products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
      when "wedding_bouquets"
        bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Свадебный" }).pluck(:id)
        @products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
      when "gift_bouquets"
        bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Подарочный" }).pluck(:id)
        @products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
      when "round_bouquets"
        bouquet_ids = Bouquet.joins(:bouquet_type).where(bouquet_types: { name: "Круглый" }).pluck(:id)
        @products = Product.where(productable_type: "Bouquet", productable_id: bouquet_ids)
      when "single_flowers"
        @products = Product.where(productable_type: "Flower")
      when "toys"
        @products = Product.where(productable_type: "Toy")
      when "vases"
        @products = Product.where(productable_type: "Vase")
      end
    end

    # Поиск по имени продукта, учитывая уже отфильтрованный набор
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
end

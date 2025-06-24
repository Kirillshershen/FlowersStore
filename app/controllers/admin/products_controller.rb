class Admin::ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.page(params[:page]).per(30) 
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
    # Для удобства при редактировании конвертируем metadata в JSON-строку (если нужно в форме)
    @product.metadata_json = @product.metadata.to_json if @product.metadata.present?
  end

def create
  # Преобразуем поля из формы в нужную структуру
  if params[:product][:flower_ids] && params[:product][:flower_quantities]
    flower_ids = params[:product].delete(:flower_ids)
    flower_quantities = params[:product].delete(:flower_quantities)

    flowers_array = flower_ids.zip(flower_quantities).map do |id, qty|
      { product_id: id, quantity: qty }
    end

    # Добавляем в metadata[:flowers]
    params[:product][:metadata] ||= {}
    params[:product][:metadata][:flowers] = flowers_array
  end

  @product = Product.new(product_params)

  if @product.save
    redirect_to admin_products_path, notice: "Продукт успешно создан"
  else
    render :new
  end
end


  def update
    # Если есть поле metadata_json (текст JSON из формы), пытаемся распарсить его и заменить metadata
    if params[:product][:metadata_json].present?
      begin
        parsed_metadata = JSON.parse(params[:product][:metadata_json])
        params[:product][:metadata] = parsed_metadata
      rescue JSON::ParserError
        @product.errors.add(:metadata, "невалидный JSON")
        render :edit and return
      end
    end

    # Убираем ненужный параметр, чтобы не попадал в mass assignment
    params[:product].delete(:metadata_json)

    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Продукт обновлен"
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Продукт удалён"
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    # Разрешаем вложенную структуру metadata с массивом цветов
    params.require(:product).permit(
      :name, :price, :product_type, :image, :description,
      metadata: [
        :bouquet_type,
        :packaging,
        :category,
        { flowers: [:product_id, :quantity] }  # важно — передать как хэш с массивом
      ]
    )
  end
end

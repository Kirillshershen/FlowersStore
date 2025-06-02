class CustomBouquetsController < ApplicationController
  def new
    # Загрузка цветов и прочего для формы
    @flowers = Product.where(product_type: "Цветок")
  end

def create
  flowers = params.dig(:bouquet, :flowers)
  packaging = params.dig(:bouquet, :packaging)
  bouquet_type = params.dig(:bouquet, :bouquet_type)

  parsed_flowers = JSON.parse(flowers)

  total_price = parsed_flowers.sum do |_, f|
    flower = Product.find(f["product_id"])
    flower.price * f["quantity"].to_i
  end

  custom_bouquet = Product.create!(
    name: "Пользовательский букет",
    product_type: "Букет",
    price: total_price,
    metadata: {
      bouquet_type: bouquet_type,
      packaging: packaging,
      flowers: parsed_flowers,
      custom: true
    }
  )

  order = current_user.orders.last || current_user.orders.create!(status: "draft", price: 0)

  ProductInOrder.create!(
    order: order,
    product: custom_bouquet,
    quantity: 1
  )

  order.update!(price: (order.price || 0) + total_price)

  redirect_to order_path(order), notice: "Пользовательский букет добавлен в ваш заказ!"
end

end

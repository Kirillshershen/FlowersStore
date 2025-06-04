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

total_price = parsed_flowers.sum do |product_id_str, quantity|
  flower = Product.find(product_id_str.to_i)
  flower.price * quantity.to_i
end

flowers_hash = parsed_flowers.each_with_index.with_object({}) do |((product_id_str, quantity), index), hash|
  hash[index.to_s] = { product_id: product_id_str.to_i, quantity: quantity.to_i }
end

custom_bouquet = Product.create!(
  name: "Пользовательский букет",
  product_type: "Букет",
  price: total_price,
  metadata: {
    bouquet_type: bouquet_type,
    packaging: packaging,
    flowers: flowers_hash,
    custom: true
  }
  
)
  image_path = Rails.root.join("app/assets/images/castom.png")
  custom_bouquet.image.attach(
    io: File.open(image_path),
    filename: "castom.png",
    content_type: "image/png"
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

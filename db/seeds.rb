# Очистка
Order.destroy_all
Product.destroy_all
User.destroy_all
User.create!(
  email: "admin@example.com",
  password: "111111",
  password_confirmation: "111111",
  admin: true
)

# === Типы цветов ===
rose = "Роза"
chrysanthemum = "Хризантема"
alstroemeria = "Альстромерия"
eustoma = "Эустома"
carnation = "Гвоздика"
hydrangea = "Гортензия"
filler =  "Филлер"

# === Цветы (теперь только в Product) ===
flower_data = [
  ["Хризантема Балтика", 9.50, chrysanthemum],
  ["Хризантема Радость", 9.50, chrysanthemum],
  ["Хризантема Ньютон", 9.50, chrysanthemum],
  ["Хризантема Ромашка", 8.50, chrysanthemum],
  ["Хризантема ДелиГрин", 8.50, chrysanthemum],
  ["Альстромерия", 7.50, alstroemeria],
  ["Эустома", 15.00, eustoma],
  ["Гвоздика", 4.00, carnation],
  ["Кустовая Гвоздика", 4.90, carnation],
  ["Герберы мини", 5.00, filler],
  ["Гортензия (Эквадор)", 28.00, hydrangea],
  ["Гортензия (Кения)", 18.00, hydrangea],
  ["Кустовые розы (обычные)", 9.50, rose],
  ["Кустовые розы (пионовидные)", 10.50, rose],
  ["Роза Родос (Кения)", 4.50, rose],
  ["Роза Ла Белле (Кения)", 4.50, rose],
  ["Роза Эксплорер", 7.50, rose],
  ["Роза Мандала", 7.50, rose],
  ["Роза Мондиаль", 7.50, rose],
  ["Роза Пинк Мондиаль", 7.50, rose],
  ["Роза Канделайт", 7.50, rose],
  ["Гипсофил белый", 8.50, filler],
  ["Гипсофил крашенный", 9.50, filler],
  ["Танацетум", 6.50, filler],
  ["Лимониум", 7.50, filler],
  ["Хамелациум", 7.50, filler]
]

flower_data.each_with_index do |(name, price, type), index|
  product = Product.create!(
    name: name,
    price: price,
    product_type: "Цветок",   # <-- изменено на русское значение
    metadata: {
      flower_type: type,
      discount: 0,  
    }
  )

  image_number = rand(1..7)
  image_path = Rails.root.join("app/assets/images/flower#{image_number}.jpg")

  product.image.attach(
    io: File.open(image_path),
    filename: "flower#{image_number}.jpg",
    content_type: "image/jpeg"
  )
end

# === Упаковки и типы букетов ===
round = "Круглый"
gift = "Подарочный"
wedding = "Свадебный"
mono = "Моно букет"
cascade = "Каскадный"
hand_tied = "Букет в руках"

pack = "Крафт"

# === 10 Ваз ===
60.times do |i|
  name = "Ваза №#{i + 1}"
  size = "Средняя"
  material = "Стекло"
  diameter = rand(8..15)
  price = rand(15.0..30.0).round(2)

  product = Product.create!(
    name: name,
    price: price,
    product_type: "Ваза",   # <-- изменено
    rating: rand(1..5),
    metadata: {
      size: size,
      material: material,
      diameter: diameter,
    }
  )

  image_path = Rails.root.join("app/assets/images/vase#{1}.jpg")
  product.image.attach(
    io: File.open(image_path),
    filename: "vase#{1}.jpg",
    content_type: "image/jpeg"
  )
end

# === 10 Игрушек ===
bear_names = [
  "Мишка Тедди", "Белый Барни", "Пушистик", "Мишка Лапочка", "Серый Бруно",
  "Карамелька", "Мишка Соня", "Топтыжка", "Шоколадка", "Бамси"
]

10.times do |i|
  name = bear_names.delete_at(rand(bear_names.length))
  size = "Маленькая"
  material = "Плюш"
  price = rand(10.0..20.0).round(2)

  product = Product.create!(
    name: name,
    price: price,
    product_type: "Игрушка",   # <-- изменено
    rating: rand(1..5),
    metadata: {
      size: size,
      material: material,
    }
  )

  image_path = Rails.root.join("app/assets/images/toy#{i + 1}.jpg")
  product.image.attach(
    io: File.open(image_path),
    filename: "toy#{i + 1}.jpg",
    content_type: "image/jpeg"
  )
end

# === 10 Букетов ===
bouquet_names = [
  "Розовая нежность", "Солнечное утро", "Весеннее настроение", "Лавандовый сон",
  "Ванильное небо", "Осенняя пора", "Зимняя сказка", "Летний бриз",
  "Малиновый звон", "Полевые цветы"
]
Packaging.create!(
  [
    { name: "Крафтовая коробка", material: "Картон", price: 3.50 },
    { name: "Прозрачный пакет", material: "Полиэтилен", price: 1.20 }
  ]
)
all_flower_ids = Product.where(product_type: "Цветок").pluck(:id)  # <-- изменено

# Создание букетов
10.times do |i|
  name = bouquet_names.delete_at(rand(bouquet_names.length))
  bouquet_type = [round, gift, wedding, mono, cascade, hand_tied].sample

  flower_ids = all_flower_ids.sample(3)
  flower_quantities = flower_ids.map { rand(3..7) }

  flowers_hash = flower_ids.zip(flower_quantities).each_with_index.with_object({}) do |((id, qty), index), hash|
    hash[index.to_s] = { product_id: id, quantity: qty }
  end

  # Изначально просто считаем сумму цен цветов без скидок
  flowers = Product.where(id: flower_ids)
  total_price = 0
  flower_ids.each_with_index do |fid, idx|
    flower = flowers.find { |f| f.id == fid }
    qty = flower_quantities[idx]
    total_price += flower.price * qty if flower
  end
  total_price = total_price.round(2)

  product = Product.create!(
    name: name,
    price: total_price,
    product_type: "Букет",
    rating: rand(1..5),
    metadata: {
      bouquet_type: bouquet_type,
      packaging: Packaging.all.sample.id,
      flowers: flowers_hash,
    }
  )

  image_path = Rails.root.join("app/assets/images/bouquet#{i + 1}.jpg")
  product.image.attach(
    io: File.open(image_path),
    filename: "bouquet#{i + 1}.jpg",
    content_type: "image/jpeg"
  )
end

# Создание акций и привязка
Promotion.destroy_all
ProductPromotion.destroy_all

promo1 = Promotion.create!(
  name: "Весеннее предложение",
  discount_type: "fixed", # или 'percent' если так принято в коде
  discount_value: 10,
  starts_at: Time.current - 1.day,
  ends_at: Time.current + 14.days,
  active: true
)

promo2 = Promotion.create!(
  name: "Скидка на вазы",
  discount_type: "fixed",
  discount_value: 5.00,
  starts_at: Time.current,
  ends_at: Time.current + 10.days,
  active: true
)

promo3 = Promotion.create!(
  name: "Счастливые игрушки",
  discount_type: "fixed",
  discount_value: 15,
  starts_at: Time.current,
  ends_at: Time.current + 7.days,
  active: true
)

promo4 = Promotion.create!(
  name: "Цветочная нежность",
  discount_type: "fixed",
  discount_value: 12,
  starts_at: Time.current,
  ends_at: Time.current + 10.days,
  active: true
)

Product.where(product_type: "Цветок").sample(5).each do |product|
  ProductPromotion.create!(product: product, promotion: promo4)
end

Product.where(product_type: "Букет").sample(5).each do |product|
  ProductPromotion.create!(product: product, promotion: promo1)
end

Product.where(product_type: "Ваза").sample(5).each do |product|
  ProductPromotion.create!(product: product, promotion: promo2)
end

Product.where(product_type: "Игрушка").sample(5).each do |product|
  ProductPromotion.create!(product: product, promotion: promo3)
end

# После создания всех промо — пересчитываем цену букетов с учётом скидок на цветы и на букеты
Product.where(product_type: "Букет").find_each do |bouquet|
  new_price = bouquet.calculated_bouquet_price
  bouquet.update(price: new_price)
end

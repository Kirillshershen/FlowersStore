# Очистка (правильный порядок)
FlowerInBouquet.destroy_all
Order.destroy_all
Product.destroy_all

Bouquet.destroy_all
Flower.destroy_all


BouquetType.destroy_all
BouquetPackaging.destroy_all
FlowerType.destroy_all


# === Типы ===
rose = FlowerType.create!(name: "Роза")
chrysanthemum = FlowerType.create!(name: "Хризантема")
alstroemeria = FlowerType.create!(name: "Альстромерия")
eustoma = FlowerType.create!(name: "Эустома")
carnation = FlowerType.create!(name: "Гвоздика")
hydrangea = FlowerType.create!(name: "Гортензия")
filler = FlowerType.create!(name: "Филлер")

# === Цветы ===
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

flower_data.each do |name, price, type|
  flower = Flower.create!(name: name, price: price, flower_type: type, discount: 0)
  product = Product.create!(
  name: name,
  price: price,
  productable: flower,
  product_type: "Цветок",
  metadata: {
    flower_type: type.name,
    category: "flower"
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
# === Типы букетов ===
round = BouquetType.create!(name: "Круглый")
gift = BouquetType.create!(name: "Подарочный")
wedding = BouquetType.create!(name: "Свадебный")
mono = BouquetType.create!(name: "Моно букет")
cascade = BouquetType.create!(name: "Каскадный")
hand_tied = BouquetType.create!(name: "Букет в руках")

pack = BouquetPackaging.create!(name: "Крафт", price: 2.0)



# === 10 Ваз ===
10.times do |i|
  name = "Ваза №#{i + 1}"
  size = "Средняя"
  material = "Стекло"
  diameter = rand(8..15)
  price = rand(15.0..30.0).round(2)

  product = Product.create!(
    name: "Ваза #{name}",
    price: price,
    product_type: "vases",
    metadata: {
      size: size,
      material: material,
      diameter: diameter,
      category: "vase"
    }
  )

  image_number = i + 1
  image_path = Rails.root.join("app/assets/images/vase#{image_number}.jpg")

  product.image.attach(
    io: File.open(image_path),
    filename: "vase#{image_number}.jpg",
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
    product_type: "toys",
    metadata: {
      size: size,
      material: material,
      category: "toy"
    }
  )

  image_number = i + 1
  image_path = Rails.root.join("app/assets/images/toy#{image_number}.jpg")

  product.image.attach(
    io: File.open(image_path),
    filename: "toy#{image_number}.jpg",
    content_type: "image/jpeg"
  )
end





# === 10 Букетов ===
bouquet_names = [
  "Розовая нежность", "Солнечное утро", "Весеннее настроение", "Лавандовый сон",
  "Ванильное небо", "Осенняя пора", "Зимняя сказка", "Летний бриз",
  "Малиновый звон", "Полевые цветы"
]


10.times do |i|
    name = bouquet_names.delete_at(rand(bouquet_names.length))
  bouquet = Bouquet.create!(
    name: name,
    bouquet_type: [round, gift,wedding,mono,cascade,hand_tied ].sample,
    bouquet_packaging: pack,
    price: rand(25.0..50.0).round(2),
    discount: 0
  )

  # Случайные цветы для букета
  Flower.order("RANDOM()").limit(3).each do |flower|
    FlowerInBouquet.create!(
      bouquet: bouquet,
      flower: flower,
      quantity: rand(3..7)
    )
  end

product = Product.create!(
  name: bouquet.name,
  price: bouquet.price,
  productable: bouquet,
  product_type: "Букет",
  metadata: {
    bouquet_type: bouquet.bouquet_type.name,
    packaging: bouquet.bouquet_packaging.name,
    flower_ids: bouquet.flowers.pluck(:id),
    category: "bouquet"
  }
)


image_number = i + 1
image_path = Rails.root.join("app/assets/images/bouquet#{image_number}.jpg")

product.image.attach(
  io: File.open(image_path),
  filename: "bouquet#{image_number}.jpg",
  content_type: "image/jpeg"
)

end

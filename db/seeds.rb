# Очистка
FlowerInBouquet.destroy_all

Product.destroy_all
Order.destroy_all
Bouquet.destroy_all
Flower.destroy_all
Toy.destroy_all
Vase.destroy_all
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
  Product.create!(name: name, price: price, productable: flower, product_type: "Цветок")
end

# === Упаковки и типы букетов ===
round = BouquetType.create!(name: "Круглый")
gift = BouquetType.create!(name: "Подарочный")
pack = BouquetPackaging.create!(name: "Крафт", price: 2.0)

# === 10 Ваз ===
10.times do |i|
  vase = Vase.create!(
    name: "Ваза №#{i + 1}",
    size: "Средняя",
    material: "Стекло",
    price: rand(15.0..30.0).round(2),
    discount: 0,
    diameter: rand(8..15)
  )
  Product.create!(
    name: "Ваза #{vase.name}",
    price: vase.price,
    productable: vase,
    product_type: "Ваза"
  )
end

# === 10 Игрушек ===
10.times do |i|
  toy = Toy.create!(
    name: "Игрушка №#{i + 1}",
    size: "Маленькая",
    material: "Плюш",
    price: rand(10.0..20.0).round(2),
    discount: 0
  )
  Product.create!(
    name: toy.name,
    price: toy.price,
    productable: toy,
    product_type: "Игрушка"
  )
end

# === 10 Букетов ===
10.times do |i|
  bouquet = Bouquet.create!(
    name: "Букет №#{i + 1}",
    bouquet_type: [round, gift].sample,
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

  Product.create!(
    name: bouquet.name,
    price: bouquet.price,
    productable: bouquet,
    product_type: "Букет"
  )
end

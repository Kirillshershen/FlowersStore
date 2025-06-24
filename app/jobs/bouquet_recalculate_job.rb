class BouquetRecalculateJob < ApplicationJob
  queue_as :default

  def perform(flower_id)
    # Находим все букеты, где есть цветок с flower_id в metadata['metadata']['flowers']
    bouquets = Product.where(product_type: 'Букет')
                     .where("metadata @> ?", { "flowers" => [{ "product_id": flower_id.to_s }] }.to_json)

    bouquets.each(&:recalculate_bouquet_price)
  end
end
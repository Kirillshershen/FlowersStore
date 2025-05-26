class ApplicationController < ActionController::Base
    before_action :set_search, :set_bouquet_types
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  def set_search
    @q = Product.ransack(params[:q])
  end
    def set_bouquet_types
  @bouquet_types = Product
                    .where(product_type: 'bouquet')
                    .pluck(Arel.sql("DISTINCT metadata->>'bouquet_type'"))
                    .compact
                    .map(&:strip)
                    .sort_by(&:downcase)
  end

end

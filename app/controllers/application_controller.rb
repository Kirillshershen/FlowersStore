class ApplicationController < ActionController::Base
  before_action :set_search, :set_bouquet_types, :load_notifications
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  def set_search
    @q = Product.ransack(params[:q])
  end
    def set_bouquet_types
    @bouquet_types = Product
                      .where(product_type: 'Букет')
                      .pluck(Arel.sql("DISTINCT metadata->>'bouquet_type'"))
                      .compact
                      .map(&:strip)
                      .sort_by(&:downcase)
  end
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
   private

  def load_notifications
    return unless user_signed_in?

    @notifications = current_user.notifications.order(created_at: :desc).limit(5)
    @unread_count = @notifications.where(read: false).count
  end
end

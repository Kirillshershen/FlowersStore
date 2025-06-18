class ApplicationController < ActionController::Base
  before_action :set_search, :set_bouquet_types, :load_notifications
    before_action :configure_permitted_parameters, if: :devise_controller?

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

    protected

  def configure_permitted_parameters
    # Разрешаем поля для регистрации (sign_up)
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
    # Разрешаем поля для редактирования профиля (account_update)
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end
end

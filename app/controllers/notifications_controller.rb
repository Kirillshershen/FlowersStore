class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # Страница со списком всех уведомлений
  def index
    @notifications = current_user.notifications.order(created_at: :desc).limit(20)
  end

  # Отметить уведомление как прочитанное
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    redirect_back(fallback_location: notifications_path)
  end
end

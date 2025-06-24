class ReviewsController < ApplicationController
  before_action :ensure_can_review, only: [:new, :create]

  def index
    @reviews = Review.includes(:user).order(created_at: :desc)
  end

  def new
    @review = Review.new
  end

  def create
    @review = current_user.reviews.build(review_params)

    if @review.save
      redirect_to reviews_path, notice: "Спасибо за ваш отзыв!"
    else
      render :new
    end
  end
def ensure_can_review
  unless current_user.can_review?
    flash[:alert] = "Вы можете оставить отзыв только после выполнения заказа"
    redirect_to root_path
  end

  if current_user.reviews.where("created_at >= ?", Time.current.beginning_of_day).exists?
    flash[:alert] = "Вы уже оставили отзыв сегодня. Следующий можно будет завтра."
    redirect_to reviews_path
  end
end
  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
  
def ensure_can_review
  unless current_user.can_review?
    flash[:alert] = "Вы можете оставить отзыв только после выполнения заказа"
    redirect_to root_path
  end

  if Review.where(user: current_user).where("created_at >= ?", Time.current.beginning_of_day).exists?
    flash[:alert] = "Вы уже оставили отзыв сегодня. Следующий можно будет завтра."
    redirect_to reviews_path
  end
end
end
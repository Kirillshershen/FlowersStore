class Review < ApplicationRecord
    before_validation :sanitize_phone
  belongs_to :user

  validates :content, presence: true, length: { minimum: 10 }
  validates :rating, presence: true, inclusion: { in: 1..5 }

  # Проверка: только один отзыв в сутки
  validate :only_one_per_day
  private

  def only_one_per_day
    if self.class.where(user: user).where("created_at >= ?", Time.current.beginning_of_day).exists?
      errors.add(:base, "Вы уже оставили отзыв сегодня")
    end
  end

def sanitize_phone
  return if phone.blank?
  self.phone = phone.gsub(/[^\d]/, '')
end
end
class User < ApplicationRecord
  # Devise модули
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Ассоциации
  has_many :orders, dependent: :destroy
  has_many :reviews  # <-- Добавьте эту строку
    has_many :notifications, dependent: :destroy
  # Метод для проверки администратора
  def admin?
    admin
  end
# app/models/user.rb
def can_review?
  orders.exists?(status: 'завершен')
end
def can_leave_review?
  can_review? && !reviews.where("created_at >= ?", Time.current.beginning_of_day).exists?
end

before_validation :sanitize_phone

def sanitize_phone
  self.phone = phone.gsub(/[^\d]/, '') if phone.present?
end
  private

  # Приватные методы (если есть) размещаются здесь
end

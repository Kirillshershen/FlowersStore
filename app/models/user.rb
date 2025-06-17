class User < ApplicationRecord
  # Devise модули
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Ассоциации
  has_many :orders, dependent: :destroy

    has_many :notifications, dependent: :destroy
  # Метод для проверки администратора
  def admin?
    admin
  end

  private

  # Приватные методы (если есть) размещаются здесь
end

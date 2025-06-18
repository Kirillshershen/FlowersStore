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
validates :phone, format: { with: /\A\+375 \(\d{2}\) \d{3}-\d{2}-\d{2}\z/, message: "введите номер в формате +375 (XX) XXX-XX-XX" }

  private

  # Приватные методы (если есть) размещаются здесь
end

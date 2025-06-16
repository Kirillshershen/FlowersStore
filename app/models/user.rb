class User < ApplicationRecord
  before_create :generate_telegram_link_token

  def admin?
    admin
  end

  def regenerate_telegram_link_token!
    update!(telegram_link_token: SecureRandom.hex(10))
  end

  private

  def generate_telegram_link_token
    self.telegram_link_token ||= SecureRandom.hex(10)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :orders, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

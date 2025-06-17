class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :order

  scope :unread, -> { where(read: false) }
end
  
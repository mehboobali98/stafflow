class Notification < ApplicationRecord
  belongs_to :sender, class_name: :User, foreign_key: :sender_id
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_id
  belongs_to :company
  STATUS = { unread: 0, read: 1 }.freeze
  scope :unread, -> { where('status = ?', STATUS[:unread]) }
  scope :read, -> { where('status = ?', STATUS[:read]) }
  scope :read_status, ->(status) { where('status = ?', status) }
end

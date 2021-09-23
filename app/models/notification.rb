class Notification < ApplicationRecord
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_id
  belongs_to :company
  STATUS = { unread: 0, read: 1 }.freeze
  scope :unread, -> { where('status = false') }
  scope :read, -> { where('status = true') }
  scope :read_status, ->(status) { where('status = ?', status) }
end

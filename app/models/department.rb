# frozen_string_literal: true

class Department < ApplicationRecord
  has_many :designations, dependent: :destroy
  has_many :users, dependent: :restrict_with_error
  belongs_to :company
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :company_id

  has_attached_file :avatar, styles: { medium: "350x350>", thumb: "100x100>" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  validates_attachment_file_name :avatar, matches: [/png\z/, /jpe?g\z/]
  validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 3.megabytes
end

# frozen_string_literal: true

class Department < ApplicationRecord
  searchkick word_start: [:name], inheritance: true, searchable: [:name]
  belongs_to :company
  has_many :users, dependent: :restrict_with_error
  has_many :designations, dependent: :restrict_with_error
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :company_id

  has_attached_file :avatar, styles: { medium: '350x350>', thumb: '100x100>' }
  validates_attachment_content_type :avatar, content_type: %r{\Aimage/.*\z}
  validates_attachment_file_name :avatar, matches: [/png\z/, /jpe?g\z/]
  validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 3.megabytes
end

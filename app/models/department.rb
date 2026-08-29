# frozen_string_literal: true

class Department < ApplicationRecord
  searchkick word_start: [:name], inheritance: true, searchable: [:name]
  belongs_to :company
  has_many :users, dependent: :restrict_with_error
  has_many :designations, dependent: :restrict_with_error
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :company_id, case_sensitive: false

  has_one_attached :avatar do |attachable|
    attachable.variant :medium, resize_to_limit: [350, 350]
    attachable.variant :thumb,  resize_to_limit: [100, 100]
  end
  validates :avatar, content_type: %w[image/png image/jpeg],
                     size: { less_than: 3.megabytes }

  def department_head
    users.find_by(role_id: User::ROLES[:department_head])
  end
end

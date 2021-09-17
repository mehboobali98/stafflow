# frozen_string_literal: true

class Designation < ApplicationRecord
  belongs_to :department
  belongs_to :company
  validates :name, presence: true
  has_many :users, dependent: :restrict_with_error
  validates_uniqueness_of :name, scope: :department_id
end

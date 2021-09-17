# frozen_string_literal: true

class Department < ApplicationRecord
  has_many :designations, dependent: :destroy
  has_many :users, dependent: :restrict_with_error
  validates :name, presence: true
  belongs_to :company
  validates_uniqueness_of :name, scope: :company_id
end

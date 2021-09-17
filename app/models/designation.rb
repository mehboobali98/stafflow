# frozen_string_literal: true

class Designation < ApplicationRecord
  belongs_to :department
  belongs_to :company
  has_many :users
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :department_id
end

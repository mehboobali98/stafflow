# frozen_string_literal: true

class Designation < ApplicationRecord
  belongs_to :department
  belongs_to :company
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :department_id
end

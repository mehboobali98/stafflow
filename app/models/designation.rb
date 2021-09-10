# frozen_string_literal: true

class Designation < ApplicationRecord
  belongs_to :department
  validates :designation_name, presence: true
  validates_uniqueness_of :designation_name, scope: :department_id
end

# frozen_string_literal: true

class Department < ApplicationRecord
  has_many :designations, dependent: :destroy
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :company_id
end

# frozen_string_literal: true

class Department < ApplicationRecord
  belongs_to :company
  has_many :designations, dependent: :destroy
  validates :name, presence: true
  validates_uniqueness_of :name
end

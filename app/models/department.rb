# frozen_string_literal: true

class Department < ApplicationRecord
  has_many :designations, dependent: :destroy
  validates :name, presence: true
end

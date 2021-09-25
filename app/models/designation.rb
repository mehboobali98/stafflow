# frozen_string_literal: true

class Designation < ApplicationRecord
  searchkick word_start: [:name], searchable: [:name]
  belongs_to :department
  belongs_to :company
  has_many :users, dependent: :restrict_with_error
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :department_id
end

# frozen_string_literal: true

class Department < ApplicationRecord
  searchkick word_start: [:name], inheritance: true, searchable: [:name]
  belongs_to :company
  has_many :designations, dependent: :destroy
  has_many :users, dependent: :restrict_with_error
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :company_id
end

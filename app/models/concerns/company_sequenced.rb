# frozen_string_literal: true

module CompanySequenced
  extend ActiveSupport::Concern

  included do
    before_create :assign_sequence_num
  end

  # sequence_num, not id, is the URL identifier: controllers load these records
  # with `find_by: :sequence_num`.
  def to_param
    sequence_num&.to_s
  end

  private

  def assign_sequence_num
    self.sequence_num = next_sequence_num if sequence_num.blank?
  end

  # unscoped because the default scope is keyed on the current tenant, which is
  # unset in seeds and rake tasks. Collisions are prevented by the unique index
  # on [company_id, sequence_num], not by this read.
  def next_sequence_num
    self.class.unscoped.where(company_id: company_id).maximum(:sequence_num).to_i + 1
  end
end

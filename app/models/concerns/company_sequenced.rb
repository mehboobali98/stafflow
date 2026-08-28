# frozen_string_literal: true

# Gives a model a `sequence_num` that counts from 1 within each company, so
# every tenant sees its own payrolls numbered 1, 2, 3 regardless of how many
# rows other tenants have. The number is also the model's URL identifier: the
# controllers load these records with `find_by: :sequence_num`, and `to_param`
# below is what puts it in generated paths.
#
# This replaces the `sequenceid` gem, which was pinned to a feature branch of a
# third-party fork and monkey-patched ActiveRecord::Base to provide the same
# two behaviours.
#
# Concurrency: the number is read and written in separate statements, so two
# simultaneous creates in one company can choose the same one. The unique index
# on [company_id, sequence_num] is what makes that safe - the second insert is
# rejected with ActiveRecord::RecordNotUnique rather than silently duplicating a
# number. Making it collision-free rather than collision-safe needs either a
# counter row per company or a lock, and neither is worth it until concurrent
# creation within a single tenant is actually a thing this app does.
module CompanySequenced
  extend ActiveSupport::Concern

  included do
    before_create :assign_sequence_num
  end

  # Routes and path helpers use the per-company number, not the primary key.
  def to_param
    sequence_num&.to_s
  end

  private

  def assign_sequence_num
    self.sequence_num = next_sequence_num if sequence_num.blank?
  end

  # unscoped because these models carry a default scope keyed on the current
  # tenant, and the number has to be correct even when the record is being
  # created outside a request - seeds and rake tasks both do this.
  #
  # MAX rather than the newest row's number: rows can be deleted, and after a
  # delete the highest id no longer holds the highest number.
  def next_sequence_num
    self.class.unscoped.where(company_id: company_id).maximum(:sequence_num).to_i + 1
  end
end

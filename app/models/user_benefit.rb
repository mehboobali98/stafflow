# frozen_string_literal: true

class UserBenefit < ApplicationRecord
  sequenceid :company, :users_benefits
  belongs_to :benefit
  belongs_to :user
  belongs_to :company
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: { message: I18n.t('users_benefit.validation.presence.') }, numericality: true

  def self.initialze_users_benefits(params, user_id)
    users_benefit_objects = []
    params['users_benefit']['sequence_num'].each_with_index do |sequence_num, index|
      benefit_object = Benefit.find_by_sequence_num!(sequence_num)
      status = benefit_object.benefit_type == 'Monthly'
      users_benefit_objects.append(UserBenefit.create(amount: params["number_field_#{index}"],
                                                      status: status,
                                                      benefit_id: benefit_object.id,
                                                      user_id: user_id))
    end
    users_benefit_objects
  end
end

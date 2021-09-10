# frozen_string_literal: true

class UserBenefit < ApplicationRecord
  belongs_to :benefit
  belongs_to :user
  belongs_to :company
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: { message: I18n.t('user_benefit.validation.presence.') }, numericality: true

  def self.initialze_user_benefits(params)
    user_benefit_objects = []
    params['user_benefit']['benefit_id'].each_with_index do |benefit_id, index|
      status = Benefit.find_by_id(benefit_id).benefit_type == 'Monthly'
      user_benefit_objects.append(UserBenefit.create(amount: params['user_benefit']['amount'][index],
                                                     status: status,
                                                     benefit_id: benefit_id,
                                                     user_id: 1))
    end
    user_benefit_objects
  end
end

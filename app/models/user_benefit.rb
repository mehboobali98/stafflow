class UserBenefit < ApplicationRecord
  belongs_to :benefit
  belongs_to :user
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: true

  def self.create_user_benefits(params)
    loop_iterator = 0
    params['user_benefit']['amount'].each do |amount|
      next if amount == ''

      new_user_benefit = UserBenefit.new(amount: amount,
                                         status: params['user_benefit']['status'][loop_iterator],
                                         benefit_id: params['user_benefit']['benefit_id'][loop_iterator],
                                         user_id: 1)
      loop_iterator += 1
      begin
        new_user_benefit.save!
      rescue ActiveRecord::RecordInvalid
        errors.add_to_base(new_user_benefit.errors.full_messages)
      end
    end
  end
end

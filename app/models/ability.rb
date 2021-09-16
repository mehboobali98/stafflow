# frozen_string_literal: true

require_relative('concerns/user_abilities')
require_relative('concerns/benefit_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities
  include BenefitAbilities
  include UserBenefitAbilities
  def initialize(user)
    define_user_abilities(user)
    define_benefit_abilities(user)
    define_user_benefit_abilities(user)
  end
end

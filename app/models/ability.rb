# frozen_string_literal: true

require_relative('concerns/user_abilities')
require_relative('concerns/benefit_abilities')

# ability class
class Ability
  include CanCan::Ability
  include UserAbilities
  include EventAbilities
  include DepartmentAbilities
  include DesignationAbilities
  include SettingsAbilities
  include BenefitAbilities
  include UsersBenefitAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_event_abilities(user)
    define_department_abilities(user)
    define_designation_abilities(user)
    define_setting_abilities(user)
    define_benefit_abilities(user)
    define_users_benefit_abilities(user)
  end
end

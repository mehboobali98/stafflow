# frozen_string_literal: true

require_relative('concerns/user_abilities')
require_relative('concerns/department_abilities')
require_relative('concerns/designation_abilities')
require_relative('concerns/settings_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities
  include DepartmentAbilities
  include DesignationAbilities
  include SettingsAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_department_abilities(user)
    define_designation_abilities(user)
    define_setting_abilities(user)
  end
end

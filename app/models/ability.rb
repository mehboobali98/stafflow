# frozen_string_literal: true

# ability class
class Ability
  include CanCan::Ability
  include UserAbilities
  include EventAbilities
  include DepartmentAbilities
  include DesignationAbilities
  include SettingsAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_event_abilities(user)
    define_department_abilities(user)
    define_designation_abilities(user)
    define_setting_abilities(user)
  end
end

# frozen_string_literal: true

require_relative('concerns/user_abilities')
require_relative('concerns/department_abilities')
require_relative('concerns/designation_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities
  include DepartmentAbilities
  include DesignationAbilities

  def initialize(user)
    define_user_abilities(user)
    define_department_abilities(user)
    define_designation_abilities(user)
  end
end

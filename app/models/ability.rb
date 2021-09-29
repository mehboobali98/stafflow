# frozen_string_literal: true

# ability class
class Ability
  include CanCan::Ability
  include UserAbilities
  include NotificationAbilities
  include EventAbilities
  include DepartmentAbilities
  include DesignationAbilities
  include SettingsAbilities
  include BenefitAbilities
  include UsersBenefitAbilities
  include PayrollAbilities
  include LeaveAbilities
  include UserLeaveAbilities
  include AppliedLeaveAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_notification_abilities(user)
    define_event_abilities(user)
    define_department_abilities(user)
    define_designation_abilities(user)
    define_setting_abilities(user)
    define_benefit_abilities(user)
    define_users_benefit_abilities(user)
    define_payroll_abilities(user)
    leave_abilities(user)
    user_leave_abilities(user)
    applied_leave_abilities(user)
  end
end

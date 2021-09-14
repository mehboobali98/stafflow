module SettingsAbilities
  def define_setting_abilities(user)
    return if !user.account_owner? && !user.hr?

    can :manage, Setting, company_id: user.company_id
    cannot %i[destroy create], Setting, company_id: user.company_id
  end
end

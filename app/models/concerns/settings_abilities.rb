module SettingsAbilities
  def define_settings_abilities(user)
    return if user.blank?

    return unless user.account_owner? || user.hr?

    can :manage, Setting, company_id: user.company_id
    cannot %i[destroy create], Setting, company_id: user.company_id
  end
end

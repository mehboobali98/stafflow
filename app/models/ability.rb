# frozen_string_literal: true

class Ability
  include CanCan::Ability
  include UserAbilities
  include SettingsAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_setting_abilities(user)
  end
end

# frozen_string_literal: true

require_relative('concerns/user_abilities')
require_relative('concerns/notification_abilities')
require_relative('concerns/settings_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities
  include NotificationAbilities
  include SettingsAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_notification_abilities(user)
    define_setting_abilities(user)
  end
end

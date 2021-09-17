# frozen_string_literal: true

require_relative('concerns/user_abilities')
require_relative('concerns/notification_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities
  include NotificationAbilities

  def initialize(user)
    return if user.blank?

    define_user_abilities(user)
    define_notification_abilities(user)
  end
end

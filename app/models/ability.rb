# frozen_string_literal: true

require_relative('concerns/user_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities
  include EventAbilities

  def initialize(user)
    define_user_abilities(user)
    define_event_abilities(user)
  end
end

# frozen_string_literal: true

require_relative('concerns/user_abilities')

class Ability
  include CanCan::Ability
  include UserAbilities

  def initialize(user)
    define_user_abilities(user)
  end
end

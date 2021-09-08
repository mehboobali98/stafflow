# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.owner?
      can :manage, User
    elsif user.hr?
      can :manage, User
      cannot :update, User, role_id: User::ROLES[:account_owner]
    elsif user.department_head?
      can :read, User, department_id: user.department_id
      can :update, User, id: user.id
    elsif user.employee?
      can :read, User, id: user.id
      can :update, User, id: user.id
    end
  end
end

# frozen_string_literal: true

class UserAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.owner?
      can :manage, User
    elsif user.hr?
      can :manage, User
      cannot :manage, User, role_id: User::ROLES[:account_owner]
    elsif user.department_head?
      can :read, User, department_id: user.department_id
      can :update, User, id: user.id
    elsif user.employee?
      can :index, User, department_id: user.department_id
      can :update, User, id: user.id
      can :show, User, id: user.id
    end
  end
end

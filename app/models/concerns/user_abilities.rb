module UserAbilities
  def define_user_abilities(user)
    if user.account_owner?
      can :manage, User, company_id: user.company_id
      cannot :destroy, User, id: user.id, company_id: user.company_id
    elsif user.hr?
      can :manage, User, company_id: user.company_id
      cannot %i[update destroy create], User, role_id: User::ROLES[:account_owner], company_id: user.company_id
    elsif user.department_head?
      can :read, User, company_id: user.company_id
      can :update, User, department_id: user.department_id, company_id: user.company_id
    elsif user.employee?
      can :read, User, company_id: user.company_id
      can :update, User, id: user.id, company_id: user.company_id
    end
  end
end

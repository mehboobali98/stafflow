module DepartmentAbilities
  def define_department_abilities(user)
    if user.account_owner? || user.hr?
      can :manage, Department, company_id: user.company_id
    elsif user.department_head?
      can :read, Department, company_id: user.company_id
      can :update, Department, id: user.department_id, company_id: user.company_id
    elsif user.employee?
      can :read, Department, company_id: user.company_id
    end
  end
end

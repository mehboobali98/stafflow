module DesignationAbilities
  def define_designation_abilities(user)
    return if user.blank?

    if user.account_owner?
      can :manage, Designation, company_id: user.company_id
    elsif user.hr?
      can :manage, Designation, company_id: user.company_id
      cannot :destroy, Designation, company_id: user.company_id
    elsif user.department_head?
      can :read, Designation, company_id: user.company_id
      can :update, Designation, department_id: user.department_id, company_id: user.company_id
    elsif user.employee?
      can :read, Designation, company_id: user.company_id
    end
  end
end

module PayrollAbilities
  def define_payroll_abilities(user)
    if user.employee?
      can :read, Payroll, user_id: user.id, company_id: user.company_id
    elsif user.department_head?
      can :read, Payroll, user: { department_id: user.department_id }
    elsif user.account_owner? || user.hr?
      can %i[read create], Payroll, company_id: user.company_id
    end
  end
end

module PayrollAbilities
  def define_payroll_abilities(user)
    can :read, Payroll, user_id: user.id, company_id: user.company_id
    can %i[read update create], Payroll, company_id: user.company_id if user.account_owner? || user.hr?
  end
end

module BenefitAbilities
  def define_benefit_abilities(user)
    if user.employee? || user.department_head?
      can :read, Benefit, company_id: user.company_id
    elsif user.hr? || user.account_owner?
      can :manage, Benefit, company_id: user.company_id
    end
  end
end

module UsersBenefitAbilities
  def define_users_benefit_abilities(user)
    if user.employee?
      can :read, UsersBenefit, id: user.id, company_id: user.company_id
    elsif user.department_head?
      can :read, UsersBenefit, company_id: user.company_id
    elsif user.hr? || user.account_owner?
      can :manage, UsersBenefit, company_id: user.company_id
      cannot %i[destroy update create], UsersBenefit, id: user.id, company_id: user.company_id
    end
  end
end

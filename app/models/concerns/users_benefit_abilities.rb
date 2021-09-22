module UsersBenefitAbilities
  def define_users_benefit_abilities(user)
    if user.employee? || user.department_head?
      can :read, UsersBenefit, company_id: user.company_id
    else
      can :manage, UsersBenefit, company_id: user.company_id
      cannot %i[destroy update create], UsersBenefit, id: user.id, company_id: user.company_id
    end
  end
end

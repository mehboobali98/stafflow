module UsersBenefitAbilities
  def define_users_benefit_abilities(user)
    return if user.blank?

    if user.employee? || user.department_head?
      can :read, UsersBenefit, company_id: user.company_id
    else
      can :manage, UsersBenefit, company_id: user.company_id
      cannot %i[destroy update create], UsersBenefit, User, id: user.id, company_id: user.company_id
    end
  end
end

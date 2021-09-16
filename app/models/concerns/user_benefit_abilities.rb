module UserBenefitAbilities
  def define_user_benefit_abilities(user)
    return if user.blank?

    if user.employee? || user.department_head?
      can :read, UserBenefit, company_id: user.company_id
    else
      can :manage, UserBenefit, company_id: user.company_id
      cannot :destroy, User, id: user.id, company_id: user.company_id
    end
  end
end

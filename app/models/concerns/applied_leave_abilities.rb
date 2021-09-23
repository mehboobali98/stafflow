module AppliedLeaveAbilities
  def applied_leave_abilities(user)
    if user.account_owner?
      can %i[read all_applied_leaves], AppliedLeave, company_id: user.company_id
    elsif user.hr?
      can :manage, AppliedLeave, company_id: user.company_id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id
      can %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
    elsif user.department_head?
      can :manage, AppliedLeave, user: { department_id: user.department_id }
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id
      can %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
    elsif user.employee?
      can %i[read create], AppliedLeave, company_id: user.company_id, user_id: user.id
      can %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                            state: %i[accepted rejected]
    end
  end
end

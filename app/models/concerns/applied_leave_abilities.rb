module AppliedLeaveAbilities
  def applied_leave_abilities(user)
    if user.account_owner?
      can :manage, AppliedLeave, company_id: user.company_id
      # cannot %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
      can :read, AppliedLeave, company_id: user.company_id
      #cannot :create, AppliedLeave, company_id: user.company_id, user_id: user.id
    elsif user.hr?
      can :manage, AppliedLeave, company_id: user.company_id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
      can %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                            state: %i[accepted rejected]
    elsif user.department_head?
      can :manage, AppliedLeave do |applied_leave|
        applied_leave.company_id = user.company_id
        applied_leave.user.department_id = user.department_id
      end
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
      can %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                            state: %i[accepted rejected]
    elsif user.employee?
      can %i[read create], AppliedLeave, company_id: user.company_id, user_id: user.id
      can %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                            state: %i[accepted rejected]
    end
  end
end

module AppliedLeaveAbilities
  def applied_leave_abilities(user)
    if user.account_owner?
      can :manage, AppliedLeave, company_id: user.company_id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
      cannot :create, AppliedLeave, company_id: user.company_id, user_id: user_id
    if user.hr?
      can :manage, AppliedLeave, company_id: user.company_id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, state: %i[accepted rejected]
    elsif user.department_head?
      can :manage, AppliedLeave do |applied_leave|
        user.department_id = applied_leave.user_id
      end
    elsif user.employee?
      can %i[read create update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                               state: %i[accepted rejected]
    end
  end
end

# dont give update option to 
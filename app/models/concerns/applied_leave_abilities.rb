module AppliedLeaveAbilities
  def applied_leave_abilities(user)
    if user.account_owner? || user.hr?
      can :manage, AppliedLeave, company_id: user.company_id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                               state: %i[accepted rejected]
    elsif user.employee?
      can %i[read create], AppliedLeave, company_id: user.company_id, user_id: user.id
      cannot %i[update destroy], AppliedLeave, company_id: user.company_id, user_id: user.id,
                                               state: %i[accepted rejected]
    end
  end
end

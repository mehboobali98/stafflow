module LeaveAbilities
  def leave_abilities(user)
    if user.account_owner? || user.hr?
      can :manage, Leave, company_id: user.company_id
      # cannot :destroy, Leave, user_leaves: { user_leave_id: :leave_id }
      cannot :destroy, Leave do |leave|
        leave.user_leaves.exists?
      end
    elsif user.department_head? || user.employee?
      can :read, Leave, company_id: user.company_id
    end
  end
end

module UserLeaveAbilities
  def user_leave_abilities(user)
    if user.account_owner? || user.hr?
      can :manage, UserLeave, company_id: user.company_id
      cannot :destroy, UserLeave do |user_leave|
        user_leave.applied_leaves.where(state: 'pending').exists?
      end
    elsif user.department_head?
      can :read, UserLeave, user: { company_id: user.company_id, department_id: user.department_id }
    elsif user.employee?
      can :read, UserLeave, company_id: user.company_id, user_id: user.id
    end
  end
end

module EventAbilities
  def define_event_abilities(user)
    return if user.blank?

    if user.account_owner?
      can :manage, Event, company_id: user.company_id
      can :display_calendar, Event, company_id: user.company_id
    elsif user.hr?
      can :manage, Event, company_id: user.company_id
      can :display_calendar, Event, company_id: user.company_id
    elsif user.department_head?
      can :manage, Event, company_id: user.company_id
      can :display_calendar, Event, company_id: user.company_id
    elsif user.employee?
      can :read, Event, company_id: user.company_id
      can :display_calendar, Event, company_id: user.company_id
    end
  end
end

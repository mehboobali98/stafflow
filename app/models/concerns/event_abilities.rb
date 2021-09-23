# frozen_string_literal: true

# Event Ability
module EventAbilities
  def define_event_abilities(user)
    if user.account_owner? || user.hr? || user.department_head?
      can :manage, Event, company_id: user.company_id
    elsif user.employee?
      can %i[read display_calendar], Event, company_id: user.company_id
    end
  end
end

module NotificationAbilities
  def define_notification_abilities(user)
    can :read, Notification, company_id: user.company_id, recipient_id: user.id
    can %i[count mark_as_read], Notification, company_id: user.company_id, recipient_id: user.id
  end
end

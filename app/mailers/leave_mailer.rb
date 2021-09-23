class LeaveMailer < ApplicationMailer
  default from: 'EMS@EMS.com'

  def request_email(emails, user, applied_leave)
    @user = user
    @applied_leave = applied_leave
    mail(to: emails, subject: 'Application for email')
  end

  def approve_leave_information(user, applied_from, applied_till, emails)
    @user = user
    @applied_from = applied_from
    @applied_till = applied_till
    mail to: user.email, subject: 'Approve Leave Information', cc: emails
  end

  def rejection_email(emails, user, applied_leave)
    @user = user
    @applied_leave = applied_leave
    mail(to: user.email, subject: 'Leave Rejection', cc: emails)
  end
end

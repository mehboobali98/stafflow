class LeaveMailer < ApplicationMailer
  def request_email(emails, user, applied_leave)
    @user = user
    @applied_leave = applied_leave
    mail(to: emails, subject: 'Application for email')
  end

  def approve_email(emails, user, applied_leave)
    @user = user
    @applied_leave = applied_leave
    mail to: user.email, subject: 'Approve Leave Information', cc: emails
  end

  def rejection_email(emails, user, applied_leave)
    @user = user
    @applied_leave = applied_leave
    mail(to: user.email, subject: 'Leave Rejection', cc: emails)
  end
end

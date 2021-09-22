class UserMailer < ApplicationMailer
  default from: 'EMS@EMS.com'

  def leave_application_email(emails, user, leave)
    @user = user
    @leave = leave
    mail(to: emails, subject: 'Application for email')
  end

  def approve_leave_information(user, emails)
    @user = user
    mail to: user.email, subject: 'Approve Leave Information', cc: emails
  end
end

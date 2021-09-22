class UserMailer < ApplicationMailer
  def leave_application_email(emails, user, leave)
    @user = user
    @leave = leave
    mail(to: emails, subject: 'Application for email')
  end
end

class UserMailer < ApplicationMailer
  def leave_application_email(emails)
    mail(to: emails, subject: 'Application for email')
  end
end

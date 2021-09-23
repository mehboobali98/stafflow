class UserMailer < ApplicationMailer
  default from: 'testaccoun1717@gmail.com'

  def send_approval_email(user, cc_emails, applied_leave)
    @user = user
    @applied_leave = applied_leave
    mail to: user.email, subject: 'Approve Leave Information', cc: cc_emails
  end
end

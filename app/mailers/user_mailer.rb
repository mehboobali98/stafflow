class UserMailer < ApplicationMailer
  default from: 'testaccoun1717@gmail.com'

  def approve_leave_information(user, emails)
    @user = user

    mail to: user.email, subject: 'Approve Leave Information', cc: emails
  end
end

class UserMailer < ApplicationMailer
  default from: 'testaccoun1717@gmail.com'

  def approve_leave_information(user, applied_from, applied_till, emails)
    @user = user
    @applied_from = applied_from
    @applied_till = applied_till
    mail to: user.email, subject: 'Approve Leave Information', cc: emails
  end
end

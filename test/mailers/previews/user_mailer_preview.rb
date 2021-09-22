# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/approve_leave_information
  def approve_leave_information
    UserMailer.approve_leave_information
  end

end

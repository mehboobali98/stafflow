# frozen_string_literal: true

# password mailer
class PasswordMailer < ApplicationMailer
  def account_password_email(user_id, current_company_id, random_password)
    current_company = Company.find(current_company_id)
    @user = current_company.users.find(user_id)
    @password = random_password
    mail to: @user.email, subject: I18n.t('mailer.password_mailer_subject')
  end
end

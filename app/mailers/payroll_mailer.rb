# frozen_string_literal: true

class PayrollMailer < ApplicationMailer
  def payroll_generation(recipient_id, user_id, current_company_id)
    current_company = Company.find(current_company_id)
    recipient_email = current_company.users.where(id: recipient_id).pluck(:email)
    @user = current_company.users.find(user_id)
    mail to: @user.email, subject: I18n.t('mailer.payroll_subject'), cc: recipient_email
  end
end

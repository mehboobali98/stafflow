class LeaveMailer < ApplicationMailer
  def request_email(recipients_ids, user_id, applied_leave_id, current_company_id)
    current_company = Company.find(current_company_id)
    @user = current_company.users.find(user_id)
    @applied_leave = current_company.applied_leaves.find(applied_leave_id)
    emails = current_company.users.where(id: recipients_ids).pluck(:email)
    mail(to: emails, subject: 'Application for email')
  end

  def approve_email(recipients_ids, user_id, applied_leave_id, current_company_id)
    current_company = Company.find(current_company_id)
    @user = current_company.users.find(user_id)
    @applied_leave = current_company.applied_leaves.find(applied_leave_id)
    emails = current_company.users.where(email: recipients_ids).pluck(:email)
    mail(to: @user.email, subject: 'Approve Leave Information', cc: emails)
  end

  def rejection_email(recipients_ids, user_id, applied_leave_id, current_company_id)
    current_company = Company.find(current_company_id)
    @user = current_company.users.find(user_id)
    @applied_leave = current_company.applied_leaves.find(applied_leave_id)
    emails = current_company.users.where(email: recipients_ids).pluck(:email)
    mail(to: @user.email, subject: 'Leave Rejection', cc: emails)
  end
end

# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    company_name = params[:user][:company_attributes][:name]
    company_subdomain = params[:user][:company_attributes][:subdomain]
    company = Company.new(name: company_name, subdomain: company_subdomain )
    @user = company.users.build(devise_parameter_sanitizer.sanitize(:sign_up))
    @user.role_id = 1
    @user.department_id = 1 # This line will be removed once DB is recreated. Due to bad migration
    if company.save
      redirect_to new_user_session_url, notice: I18n.t('messages.signed_up')
    else
      render 'devise/registrations/new'
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    permitted_attributes = [:email, :password, :first_name, :last_name, :department_id, :company_id, :date_of_birth, {company_attributes: [:name, :subdomain]}]
    devise_parameter_sanitizer.permit(:sign_up, keys: permitted_attributes)
  end

  # If you have extra params to permit, append them to the sanitizer.

  def configure_account_update_params
    permitted_attributes = %I[email password first_name last_name department_id company_id date_of_birth]
    devise_parameter_sanitizer.permit(:account_update, keys: permitted_attributes)
  end
end

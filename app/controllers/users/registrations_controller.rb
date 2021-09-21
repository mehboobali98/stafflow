# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  layout 'signup'

  # POST /resource
  def create
    company = Company.new(company_permitted_parameters)
    @user = company.users.build(devise_parameter_sanitizer.sanitize(:sign_up))
    @user.role_id = User::ROLES[:account_owner]
    is_saved = company.save

    respond_to do |format|
      if is_saved
        format.html { redirect_to new_user_session_url, notice: I18n.t('messages.signed_up') }
      else
        format.html { render 'devise/registrations/new' }
      end
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    permitted_attributes = [:email, :password, :first_name, :last_name, :department_id, :company_id, :date_of_birth, { company_attributes: [:name, :subdomain] }]
    devise_parameter_sanitizer.permit(:sign_up, keys: permitted_attributes)
  end

  # If you have extra params to permit, append them to the sanitizer.

  def configure_account_update_params
    permitted_attributes = %i[email password first_name last_name department_id company_id date_of_birth]
    devise_parameter_sanitizer.permit(:account_update, keys: permitted_attributes)
  end

  def company_permitted_parameters
    params.require(:user).require(:company_attributes).permit(:name, :subdomain)
  end
end

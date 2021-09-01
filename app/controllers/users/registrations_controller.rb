# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    params[:user][:department_id] = 1
    company = Company.new(name: params[:user][:company_attributes][:name], subdomain: params[:user][:company_attributes][:subdomain] )
    @user = company.users.build(devise_parameter_sanitizer.sanitize(:sign_up))
    @user.department_id = 1
    binding.pry
    company.save!
    redirect_to new_user_session_url, notice: 'Your account has been created'
    # super
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

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

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

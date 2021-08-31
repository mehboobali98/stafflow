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
    # binding.pry
    params[:user][:department_id] = 1
    params[:user][:company_id] = 1
    # params[:user][:first_name] = 'Abdul'
    # params[:user][:last_name] = 'Basit'
    # params[:user][:date_of_birth] = "26/08/2021".to_date

    # # params[:user][:date_of_birth] = Date.new

    # # @user = User.new(configure_sign_up_params)
    # binding.pry

    super
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

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    permitted_attributes = %i[email password first_name last_name department_id company_id date_of_birth]
    devise_parameter_sanitizer.permit(:sign_up, keys: permitted_attributes)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    permitted_attributes = %i[email password first_name last_name department_id company_id date_of_birth]
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

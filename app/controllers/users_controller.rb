# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :load_departments_and_designations, only: %i[edit create update]
  before_action :load_departments, only: %i[new index]
  before_action :set_user_password, only: :create
  has_scope :role_id
  has_scope :department_id
  has_scope :match_users_name

  # GET /members/new
  def new
    respond_to do |format|
      format.html
    end
  end

  # POST /members
  def create
    is_saved = @user.save if @user.date_of_birth_valid?(params.dig(:user, :date_of_birth)) &&
                             @user.role_id_valid?(params.dig(:user, :role_id))
    respond_to do |format|
      if is_saved
        format.html { redirect_to members_path, notice: I18n.t('messages.added_employee') }
      else
        format.html do
          flash.now[:error] = @user.errors.full_messages
          render :new, status: :unprocessable_content
        end
      end
    end
  end

  # GET /members/:id/edit
  def edit
    respond_to do |format|
      format.html
    end
  end

  # PATCH /members/:id
  def update
    is_updated = @user.update(user_params) if @user.date_of_birth_valid?(params.dig(:user, :date_of_birth)) &&
                                              @user.role_id_valid?(params.dig(:user, :role_id))
    respond_to do |format|
      if is_updated
        format.html { redirect_to member_path(@user), notice: I18n.t('messages.updated_employee') }
      else
        format.html do
          flash.now[:error] = @user.errors.full_messages
          render :edit, status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /members/:id
  def destroy
    is_destroyed = @user.destroy
    respond_to do |format|
      if is_destroyed
        format.html { redirect_to members_path, notice: I18n.t('messages.deleted_employee') }
      else
        format.html { redirect_to members_path, alert: I18n.t('messages.error_deleting') }
      end
    end
  end

  # GET /members/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET /members
  def index
    @users = apply_scopes(@users).includes(:department).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /members/edit_password
  def edit_password
    @user = current_user
    respond_to do |format|
      format.html
    end
  end

  # POST /members/update_password
  def update_password
    is_updated = current_user.update_with_password(user_params)
    respond_to do |format|
      if is_updated
        sign_in(current_user, bypass: true)
        flash[:notice] = 'Updated Password Successfully'
        format.html { redirect_to dashboard_path }
      else
        flash.now[:error] = current_user.errors.full_messages
        @user = current_user
        format.html { render :edit_password, status: :unprocessable_content }
      end
    end
  end

  private

  def user_params
    return params.require(:user).permit(current_ability.permitted_attributes(:update, @user) + [:image]) if action_name == 'update'

    params.require(:user).permit(:image, :first_name, :email, :last_name, :date_of_birth,
                                 :department_id, :password, :password_confirmation,
                                 :role_id, :base_salary, :designation_id, :country, :gender, :current_password,
                                 :password_confirmation, :password)
  end

  def load_departments_and_designations
    @designations = @user.department.designations if @user.present? && @user.persisted? && @user.department.present?
    @departments = current_company.departments
  end

  def load_departments
    @departments = current_company.departments
  end

  def set_user_password
    @user.password = @user.random_password = User.generate_password
  end
end

# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  has_scope :role_id
  has_scope :department_id
  has_scope :match_users_name

  # GET /members/new
  def new
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  # POST /members
  def create
    is_saved = @user.save if @user.date_of_birth_valid? && @user.role_id_valid?
    respond_to do |format|
      if is_saved
        format.html { redirect_to members_path, notice: I18n.t('messages.added_employee') }
      else
        format.html do
          @departments = Department.all
          render :new
        end
      end
    end
  end

  # GET /members/:id/edit
  def edit
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  # PATCH /members/:id
  def update
    is_updated = @user.update(user_params) if @user.date_of_birth_valid? && @user.role_id_valid?
    respond_to do |format|
      if is_updated
        format.html { redirect_to members_path, notice: I18n.t('messages.updated_employee') }
      else
        format.html do
          flash.now[:error] = @user.errors.full_messages
          @departments = Department.all
          render :edit
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
    @departments = Department.all
    @users = apply_scopes(@users).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def user_params
    if @user.present?
      params[:user].delete(:base_salary) if cannot?(:update_salary, @user, current_user)
      params[:user].delete(:designation_id) if cannot?(:update_designation, @user, current_user)
      params[:user].delete(:role_id) if cannot?(:update_role, @user, current_user)
      params[:user].delete(:department_id) if cannot?(:update_department, @user, current_user)
    end

    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth,
                                 :department_id, :password, :password_confirmation, :role_id, :base_salary, :designation_id)
  end
end

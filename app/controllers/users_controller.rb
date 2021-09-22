# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :load_departments_and_designations, except: %i[destroy show]
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
    is_saved = @user.save if @user.date_of_birth_valid? && @user.role_id_valid?
    respond_to do |format|
      if is_saved
        format.html { redirect_to members_path, notice: I18n.t('messages.added_employee') }
      else
        format.html do
          render :new
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
    is_updated = @user.update(update_user_params) if @user.date_of_birth_valid? && @user.role_id_valid?
    respond_to do |format|
      if is_updated
        format.html { redirect_to members_path, notice: I18n.t('messages.updated_employee') }
      else
        format.html do
          flash.now[:error] = @user.errors.full_messages
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
    @users = apply_scopes(@users).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth,
                                 :department_id, :password, :password_confirmation,
                                 :role_id, :base_salary, :designation_id)
  end

  def update_user_params
    params.require(:user).permit(current_ability.permitted_attributes(:update, @user))
  end

  def load_departments_and_designations
    @designations = @user.department.designations if @user.present? && @user.persisted?
    @departments = current_company.departments
  end
end

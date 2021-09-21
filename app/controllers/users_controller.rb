# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  has_scope :role_id
  has_scope :department_id
  has_scope :match_users_name

  # GET /members/new
  def new
    @departments = current_company.departments
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
          @departments = current_company.departments
          render :new
        end
      end
    end
  end

  # GET /members/:id/edit
  def edit
    @departments = current_company.departments
    @designations = @user.department.designations if @user.department.present?
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
          @departments = current_company.departments
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
    @departments = current_company.departments
    @users = apply_scopes(@users).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def user_params
    params.require(:user).permit(current_ability.permitted_attributes(:update, @user))
  end
end

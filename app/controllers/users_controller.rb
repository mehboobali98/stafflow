class UsersController < ApplicationController
  before_action :find_user, only: %i[edit update destroy show]

  # GET /members/new
  def new
    @user = User.new
    respond_to do |format|
      format.html { render :new }
    end
  end

  # POST /members
  def create
    @user = User.new(permit_user_params)
    if @user.validate_date_of_birth(params.dig(:user, :date_of_birth)) && @user.validate_role(params.dig(:user, :role_id))
      is_saved = @user.save
    end
    respond_to do |format|
      if is_saved
        format.html { redirect_to members_path, notice: I18n.t('messages.added_employee') }
      else
        format.html { render :new }
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
    if @user.validate_date_of_birth(params.dig(:user, :date_of_birth)) && @user.validate_role(params.dig(:user, :role_id))
      is_updated = @user.update(permit_user_params)
    end
    respond_to do |format|
      if is_updated
        format.html { redirect_to members_path, notice: I18n.t('messages.updated_employee') }
      else
        format.html { render :edit }
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
    @users = User.all
  end

  private

  def permit_user_params
    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth, :department_id, :password, :password_confirmation, :role_id, :salary)
  end

  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to members_path, alert: I18n.t('messages.user_doesnt_exist') }
    end
  end
end

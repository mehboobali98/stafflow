class UsersController < ApplicationController
  before_action :validate_role_id, only: %I[create update]
  before_action :find_user_with_id, only: %I[edit update destroy show]
  # GET /members/new
  def new
    @user = User.new
  end

  # POST /members
  def create
    @user = User.new(permit_user_params)
    @user.department_id = 1
    @user.company_id = 18
    respond_to do |format|
      if @user.save
        format.html { redirect_to members_path, notice: I18n.t('messages.added_employee') }
      else
        format.html { render :new }
      end
    end
  end

  # GET /members/:id/edit
  def edit; end

  # PATCH /members/:id
  def update
    respond_to do |format|
      if @user.update(permit_user_params)
        format.html { redirect_to members_path, notice: I18n.t('messages.updated_employee') }
      else
        format.html{ render :edit }
      end
    end
  end

  # DELETE /members/:id
  def destroy
    @user.destroy
    redirect_to members_path, notice: I18n.t('messages.deleted_employee')
  end

  # GET /members/:id
  def show; end

  # GET /members
  def index
    @users = User.all
  end

  private

  def permit_user_params
    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth, :department_id, :password, :password_confirmation, :role_id, :salary)
  end

  def validate_role_id
    return unless params[:user][:role_id].to_i == User::ROLES[:Account_Owner]

    redirect_to members_path, alert: I18n.t('messages.cannot_be_account_owner')
  end

  def find_user_with_id
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to members_path, alert: I18n.t('messages.user_doesnt_exist') }
    end
  end
end

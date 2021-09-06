class UsersController < ApplicationController
  before_action :validate_role_id, only: %I[create update]
  # GET /members/new
  def new
    @user = User.new
  end

  # POST /members
  def create
    @user = User.new(permit_user_params)
    @user.department_id = 1
    @user.company_id = 18
    if @user.save
      redirect_to members_path, notice: I18n.t('messages.added_employee')
    else
      render 'new'
    end
  end

  # GET /members/:id/edit
  def edit
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to members_path, alert: I18n.t('messages.user_doesnt_exist')
  end

  # PATCH /members/:id
  def update
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render 'index', alert: I18n.t('messages.user_doesnt_exist') and return
    if @user.update(permit_user_params)
      redirect_to members_path, notice: I18n.t('messages.updated_employee')
    else
      render 'edit'
    end
  end

  # DELETE /members/:id
  def destroy
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render 'index', alert: I18n.t('messages.user_doesnt_exist') and return
    @user.destroy
    redirect_to members_path, notice: I18n.t('messages.deleted_employee')
  end

  # GET /members/:id
  def show
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to members_path, alert: I18n.t('messages.user_doesnt_exist')
  end

  # GET /members
  def index
    @users = User.all
  end

  private

  def permit_user_params
    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth, :department_id, :password, :password_confirmation, :role_id, :salary)
  end

  def validate_role_id
    return unless params[:user][:role_id] == User::ROLES[:Account_Owner]

    redirect_to members_path, alert: I18n.t('messages.cannot_be_account_owner')
  end
end

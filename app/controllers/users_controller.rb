class UsersController < ApplicationController
  before_action :validate_role, only: %i[create update]
  before_action :find_user, only: %i[edit update destroy show]
  before_action :check_for_valid_date, only: :create
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
    @user.department_id = 1 # Temporary
    respond_to do |format|
      if @user.save
        format.html { redirect_to members_path, notice: I18n.t('messages.added_employee') }
      else
        format.html { render :new }
      end
    end
  end

  # GET /members/:id/edit
  def edit
    respond_to do |format|
      format.html { render :edit }
    end
  end

  # PATCH /members/:id
  def update
    respond_to do |format|
      if @user.update(permit_user_params)
        format.html { redirect_to members_path, notice: I18n.t('messages.updated_employee') }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /members/:id
  def destroy
    respond_to do |format|
      message = @user.destroy ? I18n.t('messages.deleted_employee') : I18n.t('messages.error_deleting')
      format.html { redirect_to members_path, notice: message }
    end
  end

  # GET /members/:id
  def show
    respond_to do |format|
      format.html { render :show }
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

  def validate_role
    return unless params[:user][:role_id].to_i == User::ROLES[:account_owner]

    redirect_to members_path, alert: I18n.t('messages.cannot_be_account_owner')
  end

  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to members_path, alert: I18n.t('messages.user_doesnt_exist') }
    end
  end

  def check_for_valid_date
    date_of_birth = params[:user][:date_of_birth]
    respond_to do |format|
      format.html { render :new, alert: I18n.t('messages.date_error') } if date_of_birth.year.to_s.length > 4
    end
  end
end

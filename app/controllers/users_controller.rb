# frozen_string_literal: true

class UsersController < ApplicationController
  PAGE_SIZE = 2
  load_and_authorize_resource except: %i[index filters]
  has_scope :role_id
  has_scope :department_id
  has_scope :match_name

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
    is_updated = @user.update(user_params) if @user.date_of_birth_valid? && @user.role_id_valid?
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
    @users = User.accessible_by(current_ability).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
      format.js { render :filters }
    end
  end

  # GET /members/filters
  def filters
    @users = apply_scopes(User).accessible_by(current_ability).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.js
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth, :department_id, :password, :password_confirmation, :role_id, :salary)
  end
end

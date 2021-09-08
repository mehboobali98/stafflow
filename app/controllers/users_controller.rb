class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(permit_user_params)
    @user.department_id = 1
    @user.company_id = 18
    if @user.save!
      redirect_to users_url, notice: 'Successfully Added Employee'
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update!(permit_user_params)
      redirect_to users_url, notice: 'Employee was updated'
    else
      render 'edit'
    end
  end

  def index
    @users = User.all.to_a
  end

  private

  def permit_user_params
    params.require(:user).permit(:first_name, :email, :last_name, :date_of_birth, :department_id, :password,
                                 :password_confirmation, :role_id)
  end
end

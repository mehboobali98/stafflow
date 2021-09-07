class UserBenefitsController < ApplicationController
  def index
    @user_benefit = UserBenefit.includes(:user)
  end

  def new
    @user_benefit = UserBenefit.includes(:benefit).all
    @benefit = Benefit.all
  end

  def create
    @benefit = Benefit.all
    @user_benefit = UserBenefit.includes(:benefit).all
    # this isn't in the model because I need flash messages I don't know how to
    # add flash messages from the model, this will be moved to the model later
    loop_iterator = 0
    params['user_benefit']['amount'].each do |amount|
      next if amount == ''

      new_user_benefit = UserBenefit.new(amount: amount,
                                         status: params['user_benefit']['status'][loop_iterator],
                                         benefit_id: params['user_benefit']['benefit_id'][loop_iterator],
                                         user_id: 1)
      loop_iterator += 1
      begin
        new_user_benefit.save!
        flash[:notice] = I18n.t('user_benefit.messages.success.')
      rescue ActiveRecord::RecordInvalid
        flash[:errors] = new_user_benefit.errors.full_messages
      end
    end
    redirect_to action: 'index'
  end

  def generate_payroll
    UserBenefit.create_applied_benefit
  end

  def show
    @user_benefit = UserBenefit.find(params[:id])
  end

  def destroy
    @user_benefit = UserBenefit.find(params[:id])
    if @user_benefit.destroy
      flash[:notice] = I18n.t('user_benefit.messages.success.delete')
    else
      flash[:errors] = @user_benefit.errors.full_messages
    end
    redirect_to action: 'index'
  end

  def update
    @user_benefit = UserBenefit.find(params[:id])
    if @user_benefit.update(user_benefit_arguments_update)
      flash[:notice] = I18n.t('user_benefit.messages.success.update')
      redirect_to action: 'index'
    else
      flash[:errors] = @user_benefit.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end

  def user_benefit_arguments_create
    params.require(:user_benefit).permit(benefit_id[], amount[], status[])
  end

  def user_benefit_arguments_update
    params.require(:user_benefit).permit(:amount, :status)
  end
end

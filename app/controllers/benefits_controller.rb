# frozen_string_literal: true

class BenefitsController < ApplicationController
  def index
    @benefit = Benefit.all
  end

  def new
    @benefit = Benefit.new
  end

  def show
    @benefit = Benefit.find(params[:id])
  end

  def update
    @benefit = Benefit.find(params[:id])
    if @benefit.update(benefit_arguments)
      flash[:notice] = I18n.t('benefit.messages.success.update')
      redirect_to action: 'index'
    else
      flash[:errors] = @benefit.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def create
    @benefit = Benefit.new(benefit_arguments)
    if @benefit.save
      flash[:notice] = I18n.t('benefit.messages.success.create')
      redirect_to action: 'index'
    else
      flash[:errors] = @benefit.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    @benefit = Benefit.find(params[:id])
    if @benefit.destroy
      flash[:notice] = I18n.t('benefit.messages.success.delete')
    else
      flash[:errors] = @benefit.errors.full_messages
    end
    redirect_to action: 'index'
  end

  def benefit_arguments
    params.require(:benefit).permit(:name, :benefit_type)
  end
end

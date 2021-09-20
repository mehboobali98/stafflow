# frozen_string_literal: true

class BenefitsController < ApplicationController
  before_action :load_benefit, only: %i[destroy update show]

  # GET /benefits
  def index
    @benefits = Benefit.all
    respond_to do |format|
      format.html
    end
  end

  # GET /benefits/new
  def new
    @benefit = Benefit.new
    respond_to do |format|
      format.html
    end
  end

  # GET /benefits/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # POST /benefits
  def create
    @benefit = Benefit.new(permitted_benefit_params.merge(status: true))
    is_saved = @benefit.save
    respond_to do |format|
      if is_saved
        flash[:notice] = t('benefit.messages.success.create')
      else
        flash[:errors] = @benefit.errors.full_messages
      end
      format.html { redirect_to benefits_path }
    end
  end

  # PATCH/PUT /benefits/:id
  def update
    is_updated = @benefit.update(permitted_benefit_params.merge(status: true))
    respond_to do |format|
      if is_updated
        flash[:notice] = t('benefit.messages.success.update')
      else
        flash[:errors] = @benefit.errors.full_messages
      end
      format.html { redirect_to benefits_path }
    end
  end

  # DELETE /benefits/:id
  def destroy
    updated = @benefit.update(status: nil)
    respond_to do |format|
      if updated
        flash[:notice] = t('benefit.messages.success.delete')
      else
        flash[:errors] = @benefit.errors.full_messages
      end
      format.html { redirect_to benefits_path }
    end
  end

  private

  def permitted_benefit_params
    params.require(:benefit).permit(:name, :benefit_type, :amount)
  end

  def load_benefit
    @benefit = Benefit.find_by!(sequence_num: params[:id])
  end
end

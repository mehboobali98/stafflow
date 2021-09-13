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

  # PATCH/PUT /benefits/:id
  def update
    is_updated = @benefit.update(permitted_benefit_params)
    respond_to do |format|
      if is_updated
        format.html { redirect_to benefits_path, notice: t('benefit.messages.success.update') }
      else
        format.html { redirect_to benefits_path, errors: @benefit.errors.full_messages }
      end
    end
  end

  # POST /benefits
  def create
    @benefit = Benefit.new(permitted_benefit_params)
    is_saved = @benefit.save
    respond_to do |format|
      if is_saved
        format.html { redirect_to benefits_path, notice: t('benefit.messages.success.create') }
      else
        format.html { redirect_to benefits_path, errors: @benefit.errors.full_messages }
      end
    end
  end

  # DELETE /benefits/:id
  def destroy
    @benefit.destroy
    respond_to do |format|
      if @benefit.destroyed?
        format.html { redirect_to benefits_path, notice: t('benefit.messages.success.delete') }
      else
        format.html { redirect_to benefits_path, errors: @benefit.errors.full_messages }
      end
    end
  end

  private

  def permitted_benefit_params
    params.require(:benefit).permit(:name, :benefit_type)
  end

  def load_benefit
    @benefit = Benefit.find(params[:id])
  end
end

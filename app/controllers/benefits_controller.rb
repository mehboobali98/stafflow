# frozen_string_literal: true

class BenefitsController < ApplicationController
  before_action :load_benefit_object, only: %i[destroy update show]

  # GET /benefits
  def index
    @benefits = Benefit.all
    respond_to do |format|
      format.html
    end
  end

  # GET /benefits/new
  def new
    @benefits = Benefit.new
    respond_to do |format|
      format.html
    end
  end

  # GET /benefits/:id
  def show; end

  # PATCH/PUT /benefits/:id
  def update
    is_updated = @benefits.update(permitted_benefit_arguments)
    respond_to do |format|
      if is_updated
        format.html { redirect_to benefits_path, notice: t('benefit.messages.success.update') }
      else
        format.html { redirect_to benefits_path, alert: is_updated.errors.full_messages }
      end
    end
  end

  # POST /benefits
  def create
    @benefits = Benefit.new(permitted_benefit_arguments)
    is_saved = @benefits.save
    respond_to do |format|
      if is_saved
        format.html { redirect_to benefits_path, notice: t('benefit.messages.success.create') }
      else
        format.html { redirect_to benefits_path, alert: is_saved.errors.full_messages }
      end
    end
  end

  # DELETE /benefits/:id
  def destroy
    is_destroyed = @benefits.destroy
    respond_to do |format|
      if is_destroyed
        format.html { redirect_to benefits_path, notice: t('benefit.messages.success.delete') }
      else
        format.html { redirect_to benefits_path, alert: is_destroyed.errors.full_messages }
      end
    end
  end

  private

  def permitted_benefit_arguments
    params.require(:benefit).permit(:name, :benefit_type)
  end

  def load_benefit_object
    @benefits = Benefit.find(params[:id])
  end
end

# frozen_string_literal: true

class BenefitsController < ApplicationController
  before_action :load_benefit, only: %i[destroy edit update]
  add_breadcrumb I18n.t('benefit.breadcrumbs.home'), :benefits_path

  # GET /benefits
  def index
    @benefits = Benefit.all.paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET /benefits/new
  def new
    add_breadcrumb t('benefit.breadcrumbs.new'), :new_benefit_path
    @benefit = Benefit.new
    respond_to do |format|
      format.html
    end
  end

  # GET /benefits/:id/edit
  def edit
    add_breadcrumb t('benefit.breadcrumbs.edit'), :edit_benefit_path
    respond_to do |format|
      format.html
    end
  end

  # POST /benefits
  def create
    @benefit = Benefit.new(permitted_benefit_params)
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
    is_updated = @benefit.update(permitted_benefit_params)
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
    @benefit.destroy
    respond_to do |format|
      if @benefit.destroyed?
        flash[:notice] = t('benefit.messages.success.delete')
      else
        flash[:errors] = @benefit.errors.full_messages
      end
      format.html { redirect_to benefits_path }
    end
  end

  private

  def permitted_benefit_params
    params.require(:benefit).permit(:name, :default_amount)
  end

  def load_benefit
    @benefit = Benefit.find_by(sequence_num: params[:id])
  end
end

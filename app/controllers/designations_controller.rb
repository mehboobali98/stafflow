# frozen_string_literal: true

class DesignationsController < ApplicationController
  before_action :find_designation_with_id, only: %I[edit update destroy]
  def index
    @designations = Designation.all
  end

  def create
    respond_to do |format|
      if Designation.exists?(permitted_designation_params)
        flash[:notice] = I18n.t 'designation.already_exist'
      else
        @designation = Designation.new(permitted_designation_params)
        if @designation.save
          flash[:notice] = I18n.t 'designation.created'
        else
          flash[:alert] = I18n.t 'designation.not_created'
        end
      end
      format.html { redirect_to action: 'index' }
    end
  end

  def edit
    @departments = Department.all
  end

  def update
    respond_to do |format|
      if Designation.exists?(permitted_designation_params)
        flash[:notice] = I18n.t 'designation.already_exist'
      elsif @designation.update(permitted_designation_params)
        flash[:notice] = I18n.t 'designation.updated'
      else
        flash[:alert] = I18n.t 'designation.not_updated'
      end
      format.html { redirect_to action: 'index' }
    end
  end

  def destroy
    @designation.destroy
    redirect_to action: 'index', notice: I18n.t('designation.destroy')
  end

  def new
    @designation = Designation.new
    @departments = Department.all
  end

  private

  def permitted_designation_params
    params.require(:designation).permit(:designation_name, :department_id)
  end

  def find_designation_with_id
    @designation = Designation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to action: 'index', alert: I18n.t('designation.not_exist') }
    end
  end
end

# frozen_string_literal: true

class DesignationsController < ApplicationController
  def index
    @designations = Designation.all
  end

  def create
    if Designation.exists?(permit_designation_params)
      flash[:notice] = I18n.t 'designation.already_exist'
    else
      @designation = Designation.new(permit_designation_params)
      if @designation.save
        flash[:notice] = I18n.t 'designation.created'
      else
        flash[:alert] = I18n.t 'designation.not_created'
      end
    end
    redirect_to action: 'index'
  end

  def edit
    @designation = Designation.find(params[:id])
    @departments = Department.all
  end

  def update
    if Designation.exists?(permit_designation_params)
      flash[:notice] = I18n.t 'designation.already_exist'
    else
      @designation = Designation.find(params[:id])
      if @designation.update(permit_designation_params)
        flash[:notice] = I18n.t 'designation.updated'
      else
        flash[:alert] = I18n.t 'designation.not_updated'
      end
    end
    redirect_to action: 'index'
  end

  def destroy
    @designation = Designation.find(params[:id])
    @designation.destroy
    flash[:notice] = I18n.t 'designation.destroy'
    redirect_to action: 'index'
  end

  def new
    @designation = Designation.new
    @departments = Department.all
  end

  private

  def permit_designation_params
    params.require(:designation).permit(:designation_name, :department_id)
  end
end

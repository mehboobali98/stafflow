# frozen_string_literal: true

class DesignationsController < ApplicationController
  def index
    @designations = Designation.all
  end

  def create
    if Designation.exists?(designation_params)
      flash[:notice] = 'Designation Already Exist'
    else
      @designation = Designation.new(designation_params)
      if @designation.save
        flash[:notice] = 'Designation Created Successfully'
      else
        flash[:alert] = 'Designation not created'
      end
    end
    redirect_to action: 'index'
  end

  def edit
    @designation = Designation.find(params[:id])
    @departments = Department.all
  end

  def update
    if Designation.exists?(designation_params)
      flash[:notice] = 'Designation Already Exist'

    else
      @designation = Designation.find(params[:id])
      if @designation.update(designation_params)
        flash[:notice] = 'Designation Updated successfully'
      else
        flash[:alert] = 'Designation not updated'
      end

    end
    redirect_to action: 'index'
  end

  def destroy
    @designation = Designation.find(params[:id])
    @designation.destroy
    flash[:notice] = 'Designation deleted successfully'
    redirect_to action: 'index'
  end

  def new
    @designation = Designation.new
    @departments = Department.all
  end

  private

  def designation_params
    params.require(:designation).permit(:designation_name, :department_id)
  end
end

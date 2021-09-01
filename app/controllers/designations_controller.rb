# frozen_string_literal: true

class DesignationsController < ApplicationController
  def index; end

  def show
    @designations = Designation.all
  end

  def create
    if Designation.exists?(designation_params)
      flash[:notice] = 'Designation Already Exist'
      render :index
    else
      @designation = Designation.new(designation_params)
      if @designation.save
        flash[:notice] = 'Designation Created Successfully'
        render :index
      else
        flash[:alert] = 'Designation not created'
        render :new
      end
    end
  end

  def edit
    @designation = Designation.find(params[:id])
    @departments = Department.all
  end

  def update
    if Designation.exists?(designation_params)
      flash[:notice] = 'Designation Already Exist'
      render :index
    else
      @designation = Designation.find(params[:id])
      if @designation.update(designation_params)
        flash[:notice] = 'Designation Updated successfully'
        render :index
      else
        flash[:alert] = 'Designation not updated'
        render :new
      end

    end
  end

  def destroy
    @designation = Designation.find(params[:id])
    flash[:notice] = 'Designation deleted successfully'
    render :show
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

# frozen_string_literal: true

class DepartmentsController < ApplicationController
  def index
    @departments = Department.all
  end

  def new
    @department = Department.new
  end

  def create
    if Department.exists?(department_params)
      flash[:notice] = 'Department Already Exist'
    else
      @department = Department.new(department_params)
      if @department.save
        flash[:notice] = 'Department Created Successfully'
      else
        flash[:alert] = 'Department not created'
      end
    end
    redirect_to action: 'index'
  end

  def edit
    @department = Department.find(params[:id])
  end

  def update
    if Department.exists?(department_params)
      flash[:notice] = 'Department Already Exist'
    else
      @department = Department.find(params[:id])
      if @department.update(department_params)
        flash[:notice] = 'Department Updated Successfully'
      else
        flash[:alert] = 'Department not updated'
      end
    end
    redirect_to action: 'index'
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    flash[:notice] = 'Department deleted successfully'
    redirect_to action: 'index'
  end

  private

  def department_params
    params.require(:department).permit(:name, :image_url)
  end
end

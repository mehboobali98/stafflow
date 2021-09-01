# frozen_string_literal: true

class DepartmentsController < ApplicationController
  def show
    @departments = Department.all
  end

  def new
    @department = Department.new
  end

  def create
    if Department.exists?(department_params)
      flash[:notice] = 'Department Already Exist'
      render :index
    else
      @department = Department.new(department_params)
      if @department.save
        flash[:notice] = 'Department Created Successfully'
        render :index
      else
        flash[:alert] = 'Department not created'
        render :new
      end
    end
  end

  def edit
    @department = Department.find(params[:id])
  end

  def update
    if Department.exists?(department_params)
      flash[:notice] = 'Department Already Exist'
      redirect_to action: 'index'
    else
      @department = Department.find(params[:id])
      if @department.update(department_params)
        flash[:notice] = 'Department Updated Successfully'
        render :index
      else
        flash[:alert] = 'Department not updated'
        render :new
      end
    end
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    flash[:notice] = 'Department deleted successfully'
    render :show
  end

  private

  def department_params
    params.require(:department).permit(:name, :image_url)
  end
end

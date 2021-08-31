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
      redirect_to action: 'index'
    else
      @department = Department.new(department_params)
      flash[:notice] = 'Department Created Successfully'
      redirect_to action: 'index' if @department.save
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
      redirect_to action: 'show' if @department.update(department_params)
    end
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    redirect_to action: 'show'
  end

  private

  def department_params
    params.require(:department).permit(:name, :image_url)
  end
end

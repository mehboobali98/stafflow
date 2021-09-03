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
      flash[:notice] = I18n.t 'department.already_exist'
    else
      @department = Department.new(department_params)
      if @department.save
        flash[:notice] = I18n.t 'department.created'
      else
        flash[:alert] = I18n.t 'department.not_created'
      end
    end
    redirect_to action: 'index'
  end

  def edit
    @department = Department.find(params[:id])
  end

  def update
    if Department.exists?(department_params)
      flash[:notice] = I18n.t 'department.already_exist'
    else
      @department = Department.find(params[:id])
      if @department.update(department_params)
        flash[:notice] = I18n.t 'department.updated'
      else
        flash[:alert] = I18n.t 'department.not_updated'
      end
    end
    redirect_to action: 'index'
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    flash[:notice] = I18n.t 'department.destroy'
    redirect_to action: 'index'
  end

  private

  def department_params
    params.require(:department).permit(:name, :image_url)
  end
end

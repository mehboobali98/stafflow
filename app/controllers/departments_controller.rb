# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :find_department_with_id, only: %I[edit update destroy]
  def index
    @departments = Department.all
  end

  def new
    @department = Department.new
  end

  def create
    respond_to do |format|
      if Department.exists?(permitted_department_params)
        flash[:notice] = I18n.t 'department.already_exist'
      else
        @department = Department.new(permitted_department_params)
        if @department.save
          flash[:notice] = I18n.t 'department.created'
        else
          flash[:alert] = I18n.t 'department.not_created'
        end
      end
      format.html { redirect_to action: 'index' }
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if Department.exists?(permitted_department_params)
        flash[:notice] = I18n.t 'department.already_exist'
      elsif @department.update(permitted_department_params)
        flash[:notice] = I18n.t 'department.updated'
      else
        flash[:alert] = I18n.t 'department.not_updated'
      end
      format.html { redirect_to action: 'index' }
    end
  end

  def destroy
    @department.destroy
    redirect_to action: 'index', notice: I18n.t('department.destroy')
  end

  private

  def permitted_department_params
    params.require(:department).permit(:name, :image_url)
  end

  def find_department_with_id
    @department = Department.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to action: 'index', alert: I18n.t('department.not_exist') }
    end
  end
end

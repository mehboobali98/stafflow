# frozen_string_literal: true

class DepartmentsController < ApplicationController
  load_and_authorize_resource

  # GET /departments
  def index
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  # GET /departments/new
  def new
    @department = Department.new
    respond_to do |format|
      format.html
    end
  end

  # POST /departments
  def create
    @department = Department.new(department_params)
    is_saved = @department.save
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to departments_path, notice: t('department.created')
        else
          flash.now[:error] = @department.errors.full_messages
          render :new
        end
      end
    end
  end

  # GET /departments/1/edit
  def edit
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /departments/1
  def update
    is_updated = @department.update(department_params)
    respond_to do |format|
      format.html do
        if is_updated
          redirect_to departments_path, notice: t('department.updated')
        else
          flash.now[:error] = @department.errors.full_messages
          redirect_to departments_path
        end
      end
    end
  end

  # DELETE /departments/1
  def destroy
    @department.destroy
    is_destroyed = @department.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @department.errors.full_messages unless is_destroyed
        flash[:notice] = t('department.destroy')
        redirect_to departments_path
      end
    end
  end

  private

  def department_params
    params.require(:department).permit(:name)
  end
end

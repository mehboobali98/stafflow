# frozen_string_literal: true

class DepartmentsController < ApplicationController
  load_and_authorize_resource
  # GET /departments
  def index
    @departments = @departments.paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET /departments/new
  def new
    respond_to do |format|
      format.html
    end
  end

  # POST /departments
  def create
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

  # GET /departments/:id/edit
  def edit
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /departments/:id
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

  # DELETE /departments/:id
  def destroy
    @department.destroy
    is_destroyed = @department.destroyed?
    respond_to do |format|
      format.html do
        if is_destroyed
          flash[:notice] = t('department.destroy')
        else
          flash[:error] = @department.errors.full_messages
        end
        redirect_to departments_path
      end
    end
  end

  # GET /departments/:id/fetch_designations
  def fetch_designations
    @designations = @department.designations
    respond_to do |format|
      format.json { render json: @designations }
    end
  end

  private

  def department_params
    params.require(:department).permit(:name)
  end
end

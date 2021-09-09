# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :find_department_with_id, only: %I[edit update destroy]

  # GET /departments
  def index
    @departments = Department.paginate(page: params[:page], per_page: $ITEMS_PER_PAGE)
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
    @department = Department.new(permitted_department_params)
    is_saved = @department.save
    respond_to do |format|
      format.html do
        return redirect_to departments_path, notice: t('department.created') if is_saved

        flash.now[:error] = @department.errors.full_messages
        render :new
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
    is_updated = @department.update(permitted_department_params)
    respond_to do |format|
      format.html do
        return redirect_to departments_path, notice: t('department.updated') if is_updated

        flash.now[:error] = @department.errors.full_messages
        redirect_to departments_path
      end
    end
  end

  # DELETE /departments/1
  def destroy
    deleted_department = @department.destroy
    is_destroyed = deleted_department.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @department.errors.full_messages unless is_destroyed
        flash[:notice] = t('department.destroy')
        redirect_to departments_path
      end
    end
  end

  private

  def permitted_department_params
    params.require(:department).permit(:name, :image_url)
  end

  def find_department_with_id
    @department = Department.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to action: 'index', alert: t('department.not_exist') }
    end
  end
end

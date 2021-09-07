# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :find_department_with_id, only: %I[edit update destroy]
  def index
    @departments = Department.paginate(page: params[:page], per_page: $ITEMS_PER_PAGE)
  end

  def new
    @department = Department.new
  end

  def create
    respond_to do |format|
      @department = Department.new(permitted_department_params)
      if @department.save
        format.html { redirect_to action: 'index', notice: I18n.t('department.created') }
      else
        format.html { render :new }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @department.update(permitted_department_params)
        format.html { redirect_to action: 'index', notice: I18n.t('department.updated') }
      else
        format.html { render :edit }
      end
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

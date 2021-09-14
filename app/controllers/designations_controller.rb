# frozen_string_literal: true

class DesignationsController < ApplicationController
  before_action :find_designation_with_id, only: %I[edit update destroy]

  # GET /designations
  def index
    @designations = Designation.paginate(page: params[:page], per_page: $ITEMS_PER_PAGE)
    respond_to do |format|
      format.html
    end
  end

  # POST /designations
  def create
    @designation = Designation.new(permitted_designation_params)
    is_saved = @designation.save
    respond_to do |format|
      format.html do
        return redirect_to designations_path, notice: t('designation.created') if is_saved

        flash.now[:error] = @designation.errors.full_messages
        redirect_to designations_path
      end
    end
  end

  # GET /designations/1/edit
  def edit
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /designations/1
  def update
    is_updated = @designation.update(permitted_designation_params)
    respond_to do |format|
      format.html do
        return redirect_to designations_path, notice: t('department.updated') if is_updated

        flash.now[:error] = @designation.errors.full_messages
        redirect_to designations_path
      end
    end
  end

  # DELETE /designations/1
  def destroy
    deleted_designation = @designation.destroy
    is_destroyed = deleted_designation.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @designation.errors.full_messages unless is_destroyed
        flash[:notice] = t('designation.destroy')
        redirect_to designations_path
      end
    end
  end

  # GET /designations/new
  def new
    @designation = Designation.new
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  private

  def permitted_designation_params
    params.require(:designation).permit(:name, :department_id)
  end

  def find_designation_with_id
    @designation = Designation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to designations_path alert: t('designation.not_exist') }
    end
  end
end

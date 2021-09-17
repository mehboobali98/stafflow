# frozen_string_literal: true

class DesignationsController < ApplicationController
  before_action :load_designation, only: %I[edit update destroy]

  # GET /designations
  def index
    @designations = Designation.paginate(page: params[:page], per_page: PAGE_SIZE)
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
        if is_saved
          redirect_to designations_path, notice: t('designation.created')
        else
          flash.now[:error] = @designation.errors.full_messages
          redirect_to designations_path
        end
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
        if is_updated
          redirect_to designations_path, notice: t('department.updated') 
        else
          flash.now[:error] = @designation.errors.full_messages
          redirect_to designations_path
        end
      end
    end
  end

  # DELETE /designations/1
  def destroy
    @designation.destroy
    is_destroyed = @designation.destroyed?
    respond_to do |format|
      format.html do
        if is_destroyed
          flash[:notice] = t('designation.destroy')
        else
          flash[:error] = @designation.errors.full_messages
        end
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

  def load_designation
    @designation = Designation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to designations_path alert: t('designation.not_exist') }
    end
  end
end

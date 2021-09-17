# frozen_string_literal: true

class DesignationsController < ApplicationController
  load_and_authorize_resource

  # GET /designations
  def index
    @designations = Designation.all
    respond_to do |format|
      format.html
    end
  end

  # POST /designations
  def create
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
    is_updated = @designation.update(designation_params)
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
        flash[:error] = @designation.errors.full_messages unless is_destroyed
        flash[:notice] = t('designation.destroy')
        redirect_to designations_path
      end
    end
  end

  # GET /designations/new
  def new
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  private

  def designation_params
    params.require(:designation).permit(:name, :department_id)
  end
end

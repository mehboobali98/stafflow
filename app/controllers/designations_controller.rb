# frozen_string_literal: true

class DesignationsController < ApplicationController
  load_and_authorize_resource

  # GET /designations
  def index
    @designations = @designations.paginate(page: params[:page], per_page: PAGE_SIZE)
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
          flash[:error] = @designation.errors.full_messages
          redirect_to designations_path
        end
      end
    end
  end

  # GET /designations/:id/edit
  def edit
    @departments = Department.all
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /designations/:id
  def update
    is_updated = @designation.update(designation_params)
    respond_to do |format|
      format.html do
        if is_updated
          redirect_to designations_path, notice: t('designation.updated') 
        else
          flash[:error] = @designation.errors.full_messages
          redirect_to designations_path
        end
      end
    end
  end

  # DELETE /designations/:id
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

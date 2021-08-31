# frozen_string_literal: true

class DesignationsController < ApplicationController
  def index; end

  def show
    @designations = Designation.all
  end

  def create
    if Designation.exists?(designation_params)
      flash[:notice] = 'Designation Already Exist'
      redirect_to action: 'index'
    else
      @designation = Designation.new(designation_params)
      flash[:notice] = 'Designation Created Successfully'
      redirect_to action: 'index' if @designation.save
    end
  end

  def edit
    @designation = Designation.find(params[:id])
    @departments = Department.all
  end

  def update
    if Designation.exists?(designation_params)
      flash[:notice] = 'Designation Already Exist'
      redirect_to action: 'index'
    else
      @designation = Designation.find(params[:id])
      redirect_to action: 'show' if @designation.update(designation_params)
    end
  end

  def destroy
    @designation = Designation.find(params[:id])
    @designation.destroy
    redirect_to action: 'show'
  end

  def new
    @designation = Designation.new
    @departments = Department.all
  end

  private

  def designation_params
    params.require(:designation).permit(:designation_name, :department_id)
  end
end

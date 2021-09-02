class LeaveTypesController < ApplicationController
  before_action :set_leave_type, only: %i[show edit update destroy]
  def index
    @leave_types = LeaveType.all
  end

  def show; end

  def new
    @leave_type = LeaveType.new
  end

  def create
    @leave_type = LeaveType.new(leave_type_params)
    if @leave_type.save
      flash[:notice] = 'Leave type created successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to create leave type'
      render :new
    end
  end

  def edit; end

  def update
    if @leave_type.update(leave_type_params)
      flash[:notice] = 'Leave type updated successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to update leave type'
      render :edit
    end
  end

  def destroy
    if @leave_type.destroy
      flash[:notice] = 'Leave type deleted successfully'
    else
      flash[:alert] = 'Unable to delete leave type'
    end
    redirect_to action: 'index'
  end

  private

  def set_leave_type
    @leave_type = LeaveType.find(params[:id])
  end

  def leave_type_params
    params.require(:leave_type).permit(:name, :count)
  end
end

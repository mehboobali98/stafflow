class LeavesController < ApplicationController
  before_action :set_leave, only: %i[show edit update destroy]
  def index
    @leaves = Leave.all
  end

  def show; end

  def new
    @leave = Leave.new
  end

  def create
    @leave = Leave.new(leave_params)
    if @leave.save
      flash[:notice] = 'Leave created successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to create leave'
      render :new
    end
  end

  def edit; end

  def update
    if @leave.update(leave_params)
      flash[:notice] = 'Leave updated successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to update leave'
      render :edit
    end
  end

  def destroy
    if @leave.destroy
      flash[:notice] = 'Leave deleted successfully'
    else
      flash[:alert] = 'Unable to delete leave'
    end
    redirect_to action: 'index'
  end

  private

  def set_leave_type
    @leave = Leave.find(params[:id])
  end

  def leave_params
    params.require(:leave).permit(:name, :count)
  end
end

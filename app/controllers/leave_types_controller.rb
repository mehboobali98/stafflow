class LeaveTypesController < ApplicationController
  before_action :set_leave_type, only: %i[show edit update destroy]
  def index
    @leave_types = LeaveType.all
  end

  def show; end

  def new
    @leave_type = LeaveType.new
  end

  def create; end

  def edit; end

  def update; end

  def destroy; end

  private

  def set_leave_type
    @leave_type = LeaveType.find(params[:id])
  end
end

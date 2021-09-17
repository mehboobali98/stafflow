class LeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave_type, only: %i[show edit update destroy]

  # GET /leaves
  def index
    @leaves = Leave.all
    respond_to do |format|
      format.html
    end
  end

  # GET /leaves/1
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET /leaves/new
  def new
    @leave = Leave.new
    respond_to do |format|
      format.html
    end
  end

  # POST /leaves
  def create
    @leave = Leave.new(leave_params)
    is_saved = @leave.save
    respond_to do |format|
      format.html do
        if is_saved
          flash[:notice] = t('leave.messages.success.create_success')
          redirect_to leaves_path
        else
          flash.now[:error] = @leave.errors.full_messages
          render :new
        end
      end
    end
  end

  # GET /leaves/1/edit
  def edit
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /leaves/1
  def update
    is_updated = @leave.update(leave_params)
    respond_to do |format|
      format.html do
        return redirect_to leaves_path, notice: t('leave.messages.success.edit_success') if is_updated

        flash.now[:error] = @leave.errors.full_messages
        render :edit
      end
    end
  end

  # DELETE /leaves/1
  def destroy
    @leave.destroy
    is_destroyed = @leave.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @leave.errors.full_messages unless is_destroyed
        flash[:notice] = I18n.t('leave.messages.success.delete_success')
        redirect_to leaves_path
      end
    end
  end

  private

  def set_leave_type
    @leave = Leave.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to leaves_path
  end

  def leave_params
    params.require(:leave).permit(:name, :count)
  end
end

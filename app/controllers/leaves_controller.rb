# frozen_string_literal: true

# Leaves controller
class LeavesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  add_breadcrumb I18n.t('leave.breadcrumbs.home'), :leaves_path

  # GET /leaves
  def index
    @leaves = @leaves.paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET /leaves/1
  def show
    add_breadcrumb t('leave.breadcrumbs.show'), :leave_path
    respond_to do |format|
      format.html
    end
  end

  # GET /leaves/new
  def new
    add_breadcrumb t('leave.breadcrumbs.new'), :new_leave_path
    respond_to do |format|
      format.html
    end
  end

  # POST /leaves
  def create
    is_saved = @leave.save
    respond_to do |format|
      format.html do
        if is_saved
          flash[:notice] = t('leave.messages.success.create_success')
          redirect_to leaves_path
        else
          flash.now[:error] = @leave.errors.full_messages
          render :new, status: :unprocessable_content
        end
      end
    end
  end

  # GET /leaves/1/edit
  def edit
    add_breadcrumb t('leave.breadcrumbs.edit'), :edit_leave_path
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /leaves/1
  def update
    is_updated = @leave.update(leave_params)
    respond_to do |format|
      format.html do
        if is_updated
          flash[:notice] = t('leave.messages.success.edit_success')
          redirect_to leaves_path
        else
          flash.now[:error] = @leave.errors.full_messages
          render :edit, status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /leaves/1
  def destroy
    @leave.destroy
    respond_to do |format|
      format.html do
        if @leave.destroyed?
          flash[:notice] = t('leave.messages.success.delete_success')
        else
          flash[:error] = @leave.errors.full_messages
        end
        redirect_to leaves_path
      end
    end
  end

  private

  def leave_params
    params.require(:leave).permit(:name, :default_count)
  end
end

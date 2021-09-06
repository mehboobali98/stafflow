class SettingsController < ApplicationController
  before_action :load_and_validate_settings, only: %I[show edit update]

  add_breadcrumb 'Home', :settings_path
  add_breadcrumb 'New', :new_setting_path

  # GET /settings/new
  def new
    @setting = Setting.new
  end

  # GET /settings
  def index
    @setting = Setting.all
  end

  # POST /settings
  def create
    @setting = Setting.new(permit_settings_parameters)
    respond_to do |format|
      if @setting.save
        format.html { redirect_to @setting, notice: 'Successfully Saved' }
      else
        format.html { render :new, notice: 'Not Saved' }
      end
    end
  end

  # GET /settings/:id/edit
  def edit; end

  # PATCH /settings/:id
  def update
    respond_to do |format|
      if @setting.update(permit_settings_parameters)
        format.html { redirect_to @setting, notice: 'Successfully updated' }
      else
        format.html { render :edit, notice: 'Not updated' }
      end
    end
  end

  # GET /settings/:id
  def show; end

  private

  def permit_settings_parameters
    params.require(:setting).permit(:tax, :theme)
  end

  def load_and_validate_settings
    @setting = Setting.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to settings_path, alert: 'Settings not found'
  end
end

class SettingsController < ApplicationController
  before_action :load_settings, only: %I[index update]

  add_breadcrumb 'Settings', :settings_path

  # GET /settings
  def index
    respond_to do |format|
      format.html { render :edit }
    end
  end

  # PATCH /settings/:id
  def update
    is_updated = @setting.update(permit_settings_parameters)
    respond_to do |format|
      if is_updated
        format.html { redirect_to settings_path, notice: I18n.t('settings.updated') }
      else
        format.html { render :edit, notice: I18n.t('settings.not_updated') }
      end
    end
  end

  private

  def load_settings
    @setting = current_company.setting
  end

  def permit_settings_parameters
    params.require(:setting).permit(:tax, :theme)
  end
end

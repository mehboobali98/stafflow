class SettingsController < ApplicationController
  before_action :authenticate_user!

  # GET /settings
  def settings
    @setting = current_company.setting
    respond_to do |format|
      format.html
    end
  end

  # PATCH /settings/:id
  def update
    @setting = current_company.setting
    is_updated = @setting.update(settings_parameters)
    respond_to do |format|
      if is_updated
        format.html { redirect_to settings_path, notice: t('settings.updated') }
      else
        format.html { render :edit, alert: t('settings.not_updated') }
      end
    end
  end

  private

  def settings_parameters
    params.require(:setting).permit(:tax, :theme)
  end
end

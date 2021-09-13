class SettingsController < ApplicationController
  # GET /settings
  def index
    @setting = current_company.setting
    respond_to do |format|
      format.html { render :edit }
    end
  end

  # PATCH /settings/:id
  def update
    @setting = current_company.setting
    is_updated = @setting.update(permit_settings_parameters)
    respond_to do |format|
      if is_updated
        format.html { redirect_to settings_path, notice: t('settings.updated') }
      else
        format.html { render :edit, notice: t('settings.not_updated') }
      end
    end
  end

  private

  def permit_settings_parameters
    params.require(:setting).permit(:tax, :theme)
  end
end

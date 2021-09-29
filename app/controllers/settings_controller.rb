class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_setting
  authorize_resource

  # GET /settings
  def settings
    respond_to do |format|
      format.html
    end
  end

  # PATCH /settings/:id
  def update
    is_updated = @setting.update(settings_params)
    respond_to do |format|
      if is_updated
        format.html { redirect_to settings_path, notice: t('settings.updated') }
      else
        format.html do
          flash.now[:alert] = @setting.errors.full_messages
          render :settings
        end
      end
    end
  end

  private

  def settings_params
    params.require(:setting).permit(:tax_rate, :theme, :leave_resets_at)
  end

  def load_setting
    @setting = current_company.setting
  end
end

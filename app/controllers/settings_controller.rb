class SettingsController < ApplicationController
  def new
    @setting = Setting.new
  end

  def create
    @setting = Setting.new(permit_settings_parameters)
    if @setting.save
      redirect_to root_url, notice: 'Settings were updated'
    else
      render 'new'
    end
  end

  private

  def permit_settings_parameters
    params.require(:setting).permit(:tax, :currency, :theme)
  end
end

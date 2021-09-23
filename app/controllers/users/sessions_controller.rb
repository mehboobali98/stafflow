# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'landing'

  protected

  def after_sign_in_path_for(_resource)
    dashboard_path
  end
end

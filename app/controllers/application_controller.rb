# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_current_company

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to members_path, alert: I18n.t('messages.unauthorized') }
    end
  end

  def current_company
    @current_company ||= Company.find_company_by_subdomain!(request.subdomain)
  end

  def set_current_company
    Company.current_company_id = current_company.id
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to '/?NoRecordFound'
  ensure
    Company.current_company_id = nil
  end

  private :current_company, :set_current_company
end

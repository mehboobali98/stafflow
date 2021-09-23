# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_current_company
  helper_method :sub_domain?
  # layout :layout_by_resource

  def layout_by_resource
    user_signed_in? ? 'application' : 'landing'
  end

  rescue_from CanCan::AccessDenied do
    respond_to do |format|
      format.html { redirect_to members_path, alert: t('messages.unauthorized') }
      format.json { render nothing: true, status: :not_found }
      format.js   { render nothing: true, status: :not_found }
    end
  end

  def current_company
    @current_company ||= Company.find_company_by_subdomain!(request.subdomain)
  end

  def set_current_company
    Company.current_company_id = current_company.id if sub_domain?(request)
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to '/?NoRecordFound'
  ensure
    Company.current_company_id = nil
  end

  private :set_current_company

  def sub_domain?(request)
    !request.subdomain.blank? && request.subdomain != 'www'
  end
end

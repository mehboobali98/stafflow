# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_current_company
  helper_method :sub_domain?

  rescue_from CanCan::AccessDenied do
    render file: 'app/views/errors/unauthorized.html', layout: false
  end

  rescue_from ActiveRecord::RecordNotFound do
    render file: 'app/views/errors/not_found.html', layout: false
  end

  rescue_from ActionController::UnknownFormat do
    flash[:error] = t('error_pages.format_error')
    redirect_to dashboard_path
  end

  def current_company
    @current_company ||= Company.find_company_by_subdomain!(request.subdomain)
  end

  def set_current_company
    Company.current_company_id = current_company.id if sub_domain?(request)
    yield
  ensure
    Company.current_company_id = nil
  end

  private :set_current_company

  def sub_domain?(request)
    !request.subdomain.blank? && request.subdomain != 'www'
  end
end

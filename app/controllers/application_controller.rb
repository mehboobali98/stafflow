# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_current_company
  helper_method :sub_domain?

  # `render file:` takes a filesystem path and serves the file verbatim, so
  # these went out as unrendered ERB and, with no status given, under 200 OK.
  # The error pages are whole documents, hence layout: false.
  rescue_from CanCan::AccessDenied do
    render template: 'errors/unauthorized', status: :forbidden, layout: false
  end

  rescue_from ActiveRecord::RecordNotFound do
    render template: 'errors/not_found', status: :not_found, layout: false
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

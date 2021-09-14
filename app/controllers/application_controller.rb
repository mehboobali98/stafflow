# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_current_company
  helper_method :sub_domain?
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
    if sub_domain?(request)
      Company.current_company_id = current_company.id
    end
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to '/?NoRecordFound'
  ensure
    Company.current_company_id = nil
  end

  private :current_company, :set_current_company

  def sub_domain?(request)
    true if !request.subdomain.blank? && request.subdomain != 'www'
  end
end

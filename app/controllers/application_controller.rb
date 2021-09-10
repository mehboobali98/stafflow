# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_current_company

  def current_company
    @current_company ||= Company.find_company_by_subdomain!(request.subdomain)
  end

  def set_current_company
    Company.current_company_id = current_company&.id
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to '/?NoRecordFound'
  ensure
    Company.current_company_id = nil
  end

  private :current_company, :set_current_company
end

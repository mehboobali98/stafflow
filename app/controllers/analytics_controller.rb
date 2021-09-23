# frozen_string_literal: true

class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  # GET /analytics
  def analytics; end

  # GET /analytics/employee_gender_distribution
  def employee_gender_distribution
    render json: @current_company.users.joins(:department).group(:gender, :name).count
  end

  # GET /analytics/monthly_payroll
  def monthly_payroll
    @data = Date::MONTHNAMES.compact.map { |month| [month, rand(10_000..500_000)] }.to_h
    render json: @data
  end
end

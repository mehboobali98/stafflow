# frozen_string_literal: true

class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def analytics; end

  def employee_gender_distribution
    render json: @current_company.users.joins(:department).group(:gender, :name).count
  end

  def monthly_payroll
    @data = Date::MONTHNAMES.compact.map { |month| [month, rand(10_000..500_000)] }.to_h
    render json: @data
  end
end

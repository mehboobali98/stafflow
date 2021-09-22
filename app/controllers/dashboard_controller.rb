# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def dashboard; end

  def anayltics; end

  def total_events
    render json: @current_company.events.size
  end

  def employees_per_department
    render json: @current_company.departments.joins(:users).group(:name).count
  end

  def employees_per_city
    render json: @current_company.departments.joins(:users).group(:city).count
  end
end

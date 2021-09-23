# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard; end

  # GET /dashboard/total_events
  def total_events
    respond_to do |format|
      format.json { render json: @current_company.events.size }
    end
  end

  # GET /dashboard/employees_per_department
  def employees_per_department
    respond_to do |format|
      format.json { render json: @current_company.departments.joins(:users).group(:name).count }
    end
  end

  # GET  /dashboard/employees_per_city
  def employees_per_city
    respond_to do |format|
      format.json { render json: @current_company.departments.joins(:users).group(:city).count }
    end
  end
end

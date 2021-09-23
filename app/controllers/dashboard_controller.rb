# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard
    @events_count = @current_company.events.size
    @upcoming_events_count = @current_company.events.where('starts_at > ?', DateTime.now).size
    @users_count = @current_company.users.all.size
    @departments_count = @current_company.departments.all.size

    respond_to do |format|
      format.html
    end
  end

  # GET /dashboard/total_events
  def total_events
    respond_to do |format|
      format.json { render json: @current_company.events.size }
    end
  end

  # GET /dashboard/employees_per_department
  def employees_per_department
    respond_to do |format|
      format.json { render json: @current_company.users.joins(:department).group('departments.name').size }
    end
  end

  # GET  /dashboard/employees_per_city
  def employees_per_city
    respond_to do |format|
      format.json { render json: @current_company.users.joins(:department).group(:city).count }
    end
  end
end

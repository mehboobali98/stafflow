# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def dashboard; end

  def total_events
    respond_to do |format|
      format.json { render json: @current_company.events.size }
    end
  end

  def employees_per_department
    respond_to do |format|
      format.json { render json: @current_company.departments.joins(:users).group(:name).count }
    end
  end

  def employees_per_city
    respond_to do |format|
      format.json { render json: @current_company.departments.joins(:users).group(:city).count }
    end
  end
end

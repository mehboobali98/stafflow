# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    binding.pry
    @current_company.users.joins(:department).group(:department_id)
  end
end

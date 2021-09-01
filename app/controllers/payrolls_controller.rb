# frozen_string_literal: true

class PayrollsController < ApplicationController
  def index
    @payrolls = Payroll.all
  end

  def show
    @payrolls = Payroll.find(params[:id])
  end

  def update; end
end

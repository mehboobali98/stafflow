# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Setting do
  let(:company) { create(:company) }

  before { Company.current_company_id = company.id }

  def setting
    Setting.unscoped.find_by!(company_id: company.id)
  end

  it 'is created automatically with the default tax rate' do
    expect(setting.tax_rate).to eq(DEFAULT_TAX_RATE)
  end

  it 'creates exactly one setting per company' do
    expect(Setting.unscoped.where(company_id: company.id).count).to eq(1)
  end

  describe 'updating' do
    before { setting.update_columns(leave_resets_at: Date.today.end_of_year) }

    it 'accepts a new tax rate' do
      setting.update!(tax_rate: 25.0)
      expect(setting.tax_rate).to eq(25.0)
    end

    # build_company_setting used to run on every save rather than only on
    # create, replacing the setting with a fresh one at DEFAULT_TAX_RATE.
    # Editing the company name silently reverted a configured tax rate, and
    # every payroll generated afterwards was wrong.
    it 'keeps the configured tax rate when the company record is updated' do
      setting.update!(tax_rate: 25.0)
      company.update!(name: 'Renamed Co')
      expect(setting.tax_rate).to eq(25.0)
    end

    it 'keeps the configured tax rate when an employee is added' do
      setting.update!(tax_rate: 25.0)
      create(:user, :employee, company: company)
      expect(setting.tax_rate).to eq(25.0)
    end

    it 'still has only one setting row after the company is updated' do
      company.update!(name: 'Renamed Co')
      expect(Setting.unscoped.where(company_id: company.id).count).to eq(1)
    end
  end

  describe 'leave_resets_at validation' do
    it 'rejects a reset date in the past' do
      setting.update_columns(leave_resets_at: Date.today.end_of_year)
      record = setting
      expect(record.update(leave_resets_at: 3.days.ago)).to be(false)
    end

    # leave_reset_date_valid? calls DateTime.parse(leave_resets_at.to_s) with
    # no nil guard, and build_company_setting never sets the column, so the
    # settings form raises rather than failing validation on a fresh company.
    it 'does not raise when leave_resets_at has never been set' do
      record = setting
      record.update_columns(leave_resets_at: nil)

      expect { record.update(tax_rate: 12.0) }.not_to raise_error
    end

    it 'saves other attributes while no reset date is set' do
      record = setting
      record.update_columns(leave_resets_at: nil)

      expect(record.update(tax_rate: 12.0)).to be(true)
      expect(record.reload.tax_rate).to eq(12.0)
    end

    it 'accepts a reset date in the future' do
      record = setting
      expect(record.update(leave_resets_at: Date.today + 30)).to be(true)
    end
  end
end

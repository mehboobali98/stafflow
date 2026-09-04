# frozen_string_literal: true

require 'rails_helper'

# The four HTML layouts each carried their own copy of the same <head>, which
# is how all four came to be missing the same three tags.
RSpec.describe 'the layout head', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  def meta(name)
    page.evaluate_script("document.querySelector('meta[name=\"#{name}\"]')?.content")
  end

  def html_lang
    page.evaluate_script('document.documentElement.lang')
  end

  shared_examples 'a document a browser can render correctly' do
    # Without this the viewport is ~980px on a phone and the whole Bootstrap
    # grid the application is built on scales down instead of reflowing.
    it 'declares the viewport' do
      expect(meta('viewport')).to eq('width=device-width, initial-scale=1')
    end

    it 'declares its character encoding' do
      expect(page).to have_css('meta[charset="utf-8"]', visible: :all)
    end

    # WCAG 3.1.1. A screen reader picks its pronunciation rules from this.
    it 'names the language of the page' do
      expect(html_lang).to eq(I18n.locale.to_s)
    end
  end

  describe 'the signup layout' do
    before { visit_apex '/' }

    it_behaves_like 'a document a browser can render correctly'
  end

  describe 'the auth layout' do
    before { visit_tenant(company, new_user_session_path) }

    it_behaves_like 'a document a browser can render correctly'
  end

  describe 'the application layout' do
    before do
      sign_in_as(company, owner)
      visit_tenant(company, members_path)
    end

    it_behaves_like 'a document a browser can render correctly'
  end

  describe 'the title' do
    it 'falls back to the application name where a view sets none' do
      visit_tenant(company, new_user_confirmation_path)

      expect(page.title).to eq(I18n.t('appname'))
    end

    it 'leads with the page name where a view sets one' do
      visit_tenant(company, new_user_session_path)

      expect(page.title).to eq("#{I18n.t('labels.signin')} · #{I18n.t('appname')}")
    end

    # Every page shared one title before this, so two different pages agreeing
    # would not have been evidence of anything.
    it 'differs between two pages that set their own' do
      sign_in_as(company, owner)
      visit_tenant(company, members_path)
      employees = page.title
      visit_tenant(company, new_member_path)

      expect(page.title).not_to eq(employees)
    end
  end
end

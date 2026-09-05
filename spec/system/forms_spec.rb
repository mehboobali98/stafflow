# frozen_string_literal: true

require 'rails_helper'

# `form.label t('forms.labels.email')` reads that translated string as the
# attribute name, so Rails writes for="user_Email" against an input whose id is
# user_email. 34 labels across 12 views did this. Nothing rendered wrong, which
# is why it survived: the text is right, the association is not, so clicking a
# label does nothing and a screen reader announces an unlabelled field.
RSpec.describe 'the forms', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  before { sign_in_as(company, owner) }

  shared_examples 'a form whose labels point at its fields' do
    it 'leaves no label pointing at an id that does not exist' do
      expect(orphaned_labels).to be_empty
    end

    it 'has labels to check in the first place' do
      expect(page).to have_css('label[for]', minimum: 2)
    end
  end

  describe 'the employee form' do
    before { visit_tenant(company, new_member_path) }

    it_behaves_like 'a form whose labels point at its fields'

    it 'renders each field through the component' do
      expect(page).to have_css('[data-component=form-field]', minimum: 9)
    end
  end

  describe 'the settings form' do
    before { visit_tenant(company, settings_path) }

    it_behaves_like 'a form whose labels point at its fields'

    # The label is not passed here, so it comes from human_attribute_name -
    # the same text form.label produced before the component.
    it 'falls back to the attribute name when given no label' do
      expect(page).to have_css('label', text: 'Tax rate')
    end
  end

  # Both of these were still calling the one-argument `form.label`, which reads
  # its translated string as the attribute name: eleven labels between them
  # pointed at ids like `user_Current Password`. The fix-in-place pass recorded
  # against phase 7 had missed them, and nothing here covered either page, so
  # they are named individually rather than left to a shared example.
  describe 'the change password form' do
    before { visit_tenant(company, edit_password_members_path) }

    it_behaves_like 'a form whose labels point at its fields'

    it 'renders each field through the component' do
      expect(page).to have_css('[data-component=form-field]', count: 3)
    end
  end

  describe 'the employee edit form' do
    let!(:employee) do
      as_tenant(company) do
        create(:user, :employee, company: company, department: department, email: 'ada@example.com')
      end
    end

    before { visit_tenant(company, edit_member_path(employee)) }

    it_behaves_like 'a form whose labels point at its fields'
  end

  # These are not converted to components yet. The association was fixed in
  # place, because a label pointing at nothing is a defect on its own and does
  # not need to wait for the view around it to be rebuilt.
  {
    'the benefit form' => :new_benefit_path,
    'the department form' => :new_department_path,
    'the designation form' => :new_designation_path
  }.each do |name, path_helper|
    describe name do
      before { visit_tenant(company, public_send(path_helper)) }

      it_behaves_like 'a form whose labels point at its fields'
    end
  end

  describe 'the signed-out forms' do
    it 'associates the labels on the sign-up page' do
      visit_apex new_user_registration_path

      expect(orphaned_labels).to be_empty
      expect(page).to have_css('label[for]', minimum: 6)
    end

    it 'associates the labels on the sign-in page' do
      Capybara.app_host = "http://#{company.subdomain}.localhost"
      visit new_user_session_path
      expect(orphaned_labels).to be_empty
      expect(page).to have_css('label[for]', minimum: 2)
    end
  end
end

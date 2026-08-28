# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersHelper do
  describe '#error_messages' do
    let(:company)    { create(:company) }
    let(:department) { create(:department, company: company) }

    before { Company.current_company_id = company.id }

    def user_with_error(attribute, message)
      user = build(:user, :employee, company: company, department: department)
      user.errors.add(attribute, message)
      assign(:user, user)
      user
    end

    it 'returns nothing when the attribute has no error' do
      assign(:user, build(:user, :employee, company: company, department: department))

      expect(helper.error_messages(:first_name)).to be_nil
    end

    it 'wraps the message in a styled span' do
      user_with_error(:first_name, 'is far too short')

      expect(helper.error_messages(:first_name))
        .to eq('<span class="text-danger">First name is far too short</span>')
    end

    # The message is assembled from I18n and from the attribute name, so it is
    # not a fixed string the helper controls. Interpolating it into an
    # html_safe string meant none of it was ever escaped.
    it 'escapes markup in the message rather than emitting it' do
      user_with_error(:first_name, '<script>alert(1)</script>')

      output = helper.error_messages(:first_name)

      expect(output).to include('&lt;script&gt;')
      expect(output).not_to include('<script>')
    end

    it 'marks its own markup as safe so the view renders the span' do
      user_with_error(:first_name, 'is invalid')

      expect(helper.error_messages(:first_name)).to be_html_safe
    end

    it 'reports the first message when an attribute has several' do
      user = build(:user, :employee, company: company, department: department)
      user.errors.add(:first_name, 'is too short')
      user.errors.add(:first_name, 'is not a name')
      assign(:user, user)

      expect(helper.error_messages(:first_name)).to include('is too short')
    end
  end
end

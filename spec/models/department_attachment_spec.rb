# frozen_string_literal: true

require 'rails_helper'

# Paperclip's styles are now named variants and its attachment validators went
# with the gem. Neither had coverage, and the variants only work if libvips is
# present in the image - the 7.0 defaults select it over ImageMagick.
RSpec.describe Department do
  subject(:department) { as_tenant(company) { create(:department, company: company) } }

  let(:company) { create(:company, subdomain: 'acme') }

  it 'accepts a PNG and processes its variant' do
    as_tenant(company) do
      department.avatar.attach(upload('avatar.png', 'image/png'))

      expect(department).to be_valid
      expect(department.avatar.variant(:medium).processed).to be_present
    end
  end

  it 'refuses a file that is not an image' do
    as_tenant(company) do
      department.avatar.attach(upload('not-an-image.txt', 'text/plain'))

      expect(department).not_to be_valid
      expect(department.errors.details[:avatar]).to include(a_hash_including(error: :content_type_invalid))
    end
  end

  it 'refuses a text file renamed and declared as a PNG' do
    as_tenant(company) do
      department.avatar.attach(upload('spoofed.png', 'image/png'))

      expect(department).not_to be_valid
      expect(department.errors.details[:avatar]).to include(a_hash_including(error: :spoofed_content_type))
    end
  end
end

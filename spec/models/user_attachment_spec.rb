# frozen_string_literal: true

require 'rails_helper'

# Paperclip's styles are now named variants and its attachment validators went
# with the gem. Neither had coverage, and the variants only work if libvips is
# present in the image - the 7.0 defaults select it over ImageMagick.
RSpec.describe User do
  subject(:user) do
    as_tenant(company) { create(:user, :employee, company: company, department: department) }
  end

  let(:company)    { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }

  it 'accepts a PNG' do
    as_tenant(company) do
      user.image.attach(upload('avatar.png', 'image/png'))

      expect(user).to be_valid
      expect(user.image).to be_attached
    end
  end

  it 'refuses a file that is not an image' do
    as_tenant(company) do
      user.image.attach(upload('not-an-image.txt', 'text/plain'))

      expect(user).not_to be_valid
      expect(user.errors.details[:image]).to include(a_hash_including(error: :content_type_invalid))
      expect(user.errors[:image].join).to match(/must be one of: /)
    end
  end

  it 'refuses a text file renamed and declared as a PNG' do
    as_tenant(company) do
      user.image.attach(upload('spoofed.png', 'image/png'))

      expect(user).not_to be_valid
      expect(user.errors.details[:image]).to include(a_hash_including(error: :spoofed_content_type))
      expect(user.errors[:image].join).to include('does not look like the image type it claims to be')
    end
  end

  it 'refuses an image over three megabytes' do
    as_tenant(company) do
      user.image.attach(oversized_png)

      expect(user).not_to be_valid
      expect(user.errors.details[:image]).to include(a_hash_including(error: :file_size_not_less_than))
      expect(user.errors[:image].join).to match(/must be smaller than /)
    end
  end

  it 'processes the medium and thumb variants that replaced the Paperclip styles' do
    as_tenant(company) do
      user.image.attach(upload('avatar.png', 'image/png'))
      user.save!

      expect(user.image.variant(:medium).processed).to be_present
      expect(user.image.variant(:thumb).processed).to be_present
    end
  end
end

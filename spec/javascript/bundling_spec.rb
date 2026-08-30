# frozen_string_literal: true

require 'rails_helper'

# esbuild resolves these to a property on its own require shim rather than
# rejecting them, so a leftover builds clean and throws when the browser runs
# it. Nothing else in the suite loads a bundle.
RSpec.describe 'JavaScript bundling' do
  webpack_only = %w[require.context require.ensure __webpack_require__ __webpack_public_path__].freeze

  subject(:sources) { Rails.root.glob('app/javascript/**/*.js') }

  it 'finds the entrypoints to check' do
    expect(sources).not_to be_empty
  end

  webpack_only.each do |api|
    it "carries no #{api} over from Webpacker" do
      offenders = sources.select { |source| source.read.include?(api) }
                         .map { |source| source.relative_path_from(Rails.root).to_s }

      expect(offenders).to be_empty
    end
  end
end

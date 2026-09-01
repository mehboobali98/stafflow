# frozen_string_literal: true

require 'rails_helper'

# esbuild resolves these to a property on its own require shim rather than
# rejecting them, so a leftover builds clean and throws when the browser runs
# it. Nothing else in the suite loads a bundle.
RSpec.describe 'JavaScript bundling' do
  webpack_only = %w[require.context require.ensure __webpack_require__ __webpack_public_path__].freeze

  subject(:sources) { Rails.root.glob('app/javascript/**/*.js') }

  # Comments are stripped before the scan, so the defect these guard against can
  # be named in the comment that explains it - which is where this codebase puts
  # its reasoning, and controllers/index.js is precisely the file with a reason
  # to mention it. Line-based rather than parsed: a `//` inside a string literal
  # takes the rest of that line with it, which can only lose a match to one of
  # the names below written after a URL on the same line.
  def code_in(source)
    source.read.gsub(%r{/\*.*?\*/}m, '').gsub(%r{//.*$}, '')
  end

  it 'finds the entrypoints to check' do
    expect(sources).not_to be_empty
  end

  webpack_only.each do |api|
    it "carries no #{api} over from Webpacker" do
      offenders = sources.select { |source| code_in(source).include?(api) }
                         .map { |source| source.relative_path_from(Rails.root).to_s }

      expect(offenders).to be_empty
    end
  end
end

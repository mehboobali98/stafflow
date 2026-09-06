# frozen_string_literal: true

require 'rails_helper'

# An icon whose name is not in the sprite renders an empty <svg>: the <use>
# resolves to nothing, the page still loads, no request fails and nothing is
# logged. It is exactly the shape of defect this phase kept finding by opening
# pages, so it is checked here instead.
RSpec.describe 'the icon sprite' do
  let(:icon_call) { /IconComponent\.new\(\s*:'?([a-z0-9-]+)'?/ }
  let(:views) do
    Rails.root.glob('app/{views,components}/**/*.erb') +
      Rails.root.glob('spec/components/previews/**/*.erb')
  end
  let(:defined_names) { IconSpriteHelper.icon_names }
  let(:asked_names) { views.flat_map { |file| file.read.scan(icon_call).flatten }.uniq }

  it 'defines at least the icons the application draws' do
    expect(defined_names).not_to be_empty
  end

  it 'defines every icon any view asks for' do
    expect(asked_names - defined_names).to be_empty
  end

  # A symbol nothing references is dead weight in every document, since the
  # sprite is inlined into all three layouts.
  it 'defines no icon the application never draws' do
    expect(defined_names - asked_names).to be_empty
  end
end

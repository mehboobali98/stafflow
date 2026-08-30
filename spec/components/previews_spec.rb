# frozen_string_literal: true

require 'rails_helper'

# Previews are the design system's front door, and they rot silently: nothing
# else renders them, so a component whose API moves leaves a preview that
# raises only when somebody opens Lookbook. Every scenario is rendered here.
RSpec.describe 'component previews', type: :component do
  Rails.root.glob('spec/components/previews/*_preview.rb').each { |file| require file }

  ViewComponent::Preview.descendants.sort_by(&:name).each do |preview|
    preview.public_instance_methods(false).sort.each do |scenario|
      it "renders #{preview.name}##{scenario}" do
        expect { render_preview(scenario, from: preview) }.not_to raise_error
      end
    end
  end
end

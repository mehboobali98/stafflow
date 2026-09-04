# frozen_string_literal: true

require 'rails_helper'

# The first specs here that run the JavaScript rather than assert on the markup
# that asks for it. spec/javascript/bundling_spec.rb greps the sources for the
# Webpack APIs esbuild silently accepts; this loads what those sources build
# into and looks at the result.
RSpec.describe 'the landing page', type: :system do
  before { visit_apex }

  it 'renders on the apex host, where no tenant is resolved' do
    expect(page).to have_css('header#header')
    expect(page).to have_link(I18n.t('forms.buttons.signin'))
  end

  # application.js is a single bundle, and a throw partway through leaves
  # everything below it undefined while the page still answers 200 with complete
  # markup - the shape the require.context defect shipped in, through a review
  # and two releases. Chartkick is the last thing the bundle registers, so it
  # answering means the whole of it ran.
  it 'runs the bundle to the end' do
    expect(js_type('window.Chartkick')).to eq('object')
  end

  # jQuery left with select2. Nothing should be putting it back.
  it 'needs no jQuery on the window' do
    expect(js_type('window.jQuery')).to eq('undefined')
    expect(js_type('window.$')).to eq('undefined')
  end

  # AOS marks the elements it takes over, so this is the Stimulus controller
  # that starts it having connected.
  it 'reveals the sections through the animate-on-scroll controller' do
    expect(page).to have_css('[data-aos].aos-init')
  end
end

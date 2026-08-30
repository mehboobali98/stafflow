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

  # application.js is a single bundle, and these are the globals it hangs off
  # window in order. A throw partway through leaves every later one undefined
  # while the page still answers 200 with complete markup - the shape the
  # require.context defect shipped in, through a review and two releases.
  it 'leaves the bundle globals on window' do
    expect(js_type('window.jQuery')).to eq('function')
    expect(js_type('window.$')).to eq('function')
    expect(js_type('window.jQuery?.fn?.select2')).to eq('function')
    expect(js_type('window.jQuery?.fn?.tooltip')).to eq('function')
    expect(js_type('window.Chartkick')).to eq('object')
  end

  # landing_page.js is a second entrypoint that reads $ off the window above and
  # calls AOS.init from $(document).ready. AOS marks the elements it takes over,
  # so this asserts the dependency between the two bundles actually held.
  it 'runs the second bundle that reads jQuery off that window' do
    expect(page).to have_css('[data-aos].aos-init')
  end
end

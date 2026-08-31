# frozen_string_literal: true

# Request specs separate origins with `host!`. A browser has no equivalent, so
# system specs steer the tenant by moving Capybara's app_host between the apex
# and a subdomain of it.
module SystemHelpers
  APEX_HOST = 'http://localhost'

  def visit_apex(path = '/')
    Capybara.app_host = APEX_HOST
    visit path
  end

  def visit_tenant(company, path)
    Capybara.app_host = "http://#{company.subdomain}.localhost"
    visit path
  end

  # The wait at the end is load-bearing, and it was not needed under turbolinks.
  # A native form submission blocks the browser until the next document is
  # there; Turbo submits with fetch, so `click_on` returns while the visit it
  # started is still in flight. Every caller here signs in and then visits
  # somewhere, and without this that visit races Turbo - which lands after it
  # and replaces the page the example was about to work on. It failed roughly
  # one run in three, on whichever example got there first, as `fill_in`
  # failing to find a field that is on the page it asked for.
  def sign_in_as(company, user, password: 'password123')
    visit_tenant(company, new_user_session_path)
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: password
    click_on I18n.t('forms.buttons.signin')
    expect(page).to have_current_path(dashboard_path)
  end

  # `typeof` rather than the value itself: these are functions and constructors,
  # which do not survive the trip back from the browser. Write the expression
  # with optional chaining, so a missing global reads as 'undefined' instead of
  # throwing on the way to the assertion.
  def js_type(expression)
    page.evaluate_script("typeof (#{expression})")
  end
end

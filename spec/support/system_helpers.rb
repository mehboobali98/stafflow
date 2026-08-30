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

  def sign_in_as(company, user, password: 'password123')
    visit_tenant(company, new_user_session_path)
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: password
    click_on I18n.t('forms.buttons.signin')
  end

  # `typeof` rather than the value itself: these are functions and constructors,
  # which do not survive the trip back from the browser. Write the expression
  # with optional chaining, so a missing global reads as 'undefined' instead of
  # throwing on the way to the assertion.
  def js_type(expression)
    page.evaluate_script("typeof (#{expression})")
  end
end

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('STAFFLOW_MAILER_FROM', 'noreply@stafflow.example')
  layout 'mailer'
end

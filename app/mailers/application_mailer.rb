# Base mailer class
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'noreply@taskcollab.com')
  layout 'mailer'
end

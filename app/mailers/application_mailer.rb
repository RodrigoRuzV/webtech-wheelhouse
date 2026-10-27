class ApplicationMailer < ActionMailer::Base
  # Lab 11: every email says it comes from the workshop. In development no
  # email leaves the machine (letter_opener, config/environments/development.rb),
  # so the address only has to look right, not exist.
  default from: "Wheelhouse <no-reply@wheelhouse.test>"
  layout "mailer"
end

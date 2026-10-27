# Preview all emails at http://localhost:3000/rails/mailers/welcome_mailer
class WelcomeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/welcome_mailer/welcome
  # Uses an account of the seed when there is one; an unsaved account
  # otherwise, so the preview renders on an empty database too.
  def welcome
    user = User.first || User.new(email_address: "ana@wheelhouse.test")
    WelcomeMailer.with(user: user).welcome
  end
end

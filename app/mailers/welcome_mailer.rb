# Lab 11: the email a new account receives. Sent with deliver_later from
# RegistrationsController#create, so it leaves from a job after the response,
# the same way the generator sends the password email.
class WelcomeMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    @sign_in_url = new_session_url

    mail to: @user.email_address, subject: "Welcome to Wheelhouse"
  end
end

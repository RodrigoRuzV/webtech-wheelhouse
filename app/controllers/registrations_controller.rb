# Lab 11: signing up. Not written by the generator (Rails 8.1's generator
# has no sign-up), so it is written here, following its sessions controller.
#
# The permitted list is the email address and the two passwords, and nothing
# else: a request that sends user[role] or user[staff_member_id] by hand has
# them dropped, and the account gets the default role and no member of the
# staff. Both are changed only from the seed or the console.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      # After the response, from a job — never inside the request.
      WelcomeMailer.with(user: @user).welcome.deliver_later
      redirect_to after_authentication_url, notice: "Welcome to Wheelhouse. Your account was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def registration_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end

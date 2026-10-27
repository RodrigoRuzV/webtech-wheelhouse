module ApplicationHelper
  # Lab 11: how an account is named on a page — the name of its member of
  # the staff, or its email address when the account belongs to no one.
  def account_label(user)
    user.staff_member&.name || user.email_address
  end
end

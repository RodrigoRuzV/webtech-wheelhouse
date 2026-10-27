class User < ApplicationRecord
  # Lab 11: the shortest password accepted. The forms read it from here.
  MIN_PASSWORD_LENGTH = 10

  has_secure_password
  has_many :sessions, dependent: :destroy

  # Lab 11: the member of the staff this account belongs to, if any. The
  # unique index on users.staff_member_id keeps it to one account each.
  belongs_to :staff_member, optional: true
  has_many :intake_repairs, class_name: "Repair", foreign_key: :intake_user_id,
           inverse_of: :intake_user, dependent: :restrict_with_error

  # The only place the role names are written, besides the migration (its
  # default) and the seed. The column is a string; mechanic is the default
  # (docs/decisions.md). Changing a role is done from the seed or the
  # console: no page and no permitted list includes it.
  enum :role, {
    owner: "owner",
    mechanic: "mechanic",
    counter: "counter"
  }, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" },
    uniqueness: { case_sensitive: false }
  # allow_nil: an account that is saved without touching its password (a
  # change of role in the console) keeps the one it has. has_secure_password
  # already requires one on create.
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH,
    message: "is too short (at least #{MIN_PASSWORD_LENGTH} characters)" }, allow_nil: true
  validates :staff_member_id, uniqueness: true, allow_nil: true
end

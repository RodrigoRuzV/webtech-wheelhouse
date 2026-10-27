# Written by the Rails 8 authentication generator; Lab 11 adds the role and
# the member of the staff before it was first run.
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      # A bcrypt digest (has_secure_password). No column holds a password.
      t.string :password_digest, null: false

      # Lab 11: owner, mechanic or counter (an enum in User). The default is
      # the role with the fewest permissions — see docs/decisions.md.
      t.string :role, null: false, default: "mechanic"

      # Lab 11: an account may belong to one member of the staff, and a
      # member of the staff has at most one account: the foreign key and
      # the unique index enforce both. NULL is allowed (an account of no one).
      t.references :staff_member, null: true, foreign_key: true, index: { unique: true }

      t.timestamps
    end
    # email_address is stored downcased (normalizes in User), so this index
    # refuses Ana@Wheelhouse.cl when ana@wheelhouse.cl exists.
    add_index :users, :email_address, unique: true
  end
end

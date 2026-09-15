class AddCustomerToBikes < ActiveRecord::Migration[8.1]
  def change
    add_reference :bikes, :customer, null: false, foreign_key: true
  end
end

class RepairJob < ApplicationRecord
  belongs_to :repair
  belongs_to :service
end

module RepairsHelper
  # Mirrors the "Derived, or stored?" decision in docs/domain-model.md:
  # overdue is never a column, it's promised_on in the past on a repair
  # that hasn't come back yet.
  def overdue?(repair)
    repair.promised_on.present? &&
      repair.promised_on < Date.current &&
      !%w[ready_for_pickup picked_up].include?(repair.status)
  end

  def status_label(status)
    status.tr("_", " ").capitalize
  end
end

module RepairsHelper
  def status_label(status)
    status.tr("_", " ").capitalize
  end
end

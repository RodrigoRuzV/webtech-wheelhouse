module RepairsHelper
  DIAGNOSIS_EXCERPT_LENGTH = 60

  # Lab 9: the beginning of the diagnosis for a row of a list, as plain text
  # on one line: Action Text's to_plain_text drops every tag and decodes
  # every entity, squish joins the lines, and ERB escapes the result like any
  # other string, so neither a tag nor an entity can show up in it.
  def diagnosis_excerpt(repair)
    text = repair.diagnosis.to_plain_text.squish
    text.present? ? text.truncate(DIAGNOSIS_EXCERPT_LENGTH) : "—"
  end

  # Lab 9: the alt of an intake photo names the bike and the repair, never
  # the file. "Intake photo 2 of 3 of the Trek Marlin 5 (serial WTU-1234),
  # repair #18"
  def intake_photo_alt(repair, position, count)
    bike = repair.bike
    "Intake photo #{position} of #{count} of the #{bike.make} #{bike.model} " \
      "(serial #{bike.serial_number}), repair ##{repair.id}"
  end

  def status_label(status)
    status.tr("_", " ").capitalize
  end
end

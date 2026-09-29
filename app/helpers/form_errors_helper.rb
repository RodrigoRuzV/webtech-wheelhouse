# Helpers that turn a model's errors into Bootstrap's server-side
# validation markup: the field gets .is-invalid and its own messages are
# shown under it in an .invalid-feedback. A field without errors gets
# neither.
module FormErrorsHelper
  # CSS classes for a field. Pass every attribute whose errors belong to
  # this field — a belongs_to select, for example, is sent as :bike_id but
  # "Bike must exist" is attached to :bike.
  def field_class(form, *attributes, base: "form-control")
    field_has_errors?(form, attributes) ? "#{base} is-invalid" : base
  end

  # The field's own messages, as full sentences, or nothing at all.
  def field_errors(form, *attributes)
    messages = attributes.flat_map { |attribute| form.object.errors.full_messages_for(attribute) }.uniq
    return if messages.empty?

    tag.div(safe_join(messages, tag.br), class: "invalid-feedback")
  end

  private

  def field_has_errors?(form, attributes)
    attributes.any? { |attribute| form.object.errors[attribute].any? }
  end
end

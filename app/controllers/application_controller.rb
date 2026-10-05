class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Lab 9: everything a row of a list of repairs (repairs/_repair) reads
  # besides the bike and the customer, loaded in a fixed number of queries
  # whatever the number of repairs and photos:
  # - with_attached_photos (Active Storage): the attachments and their blobs;
  # - the variant records of those blobs and their images, so a variant
  #   that has already been generated is found without one query per photo;
  # - with_rich_text_diagnosis_and_embeds (Action Text): the diagnosis and
  #   any file embedded in it, which to_plain_text also reads.
  def with_photos_and_diagnosis(repairs)
    repairs
      .with_attached_photos
      .with_rich_text_diagnosis_and_embeds
      .includes(photos_attachments: { blob: { variant_records: { image_attachment: :blob } } })
  end
end

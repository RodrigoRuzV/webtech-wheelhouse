class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :intake_staff, class_name: "StaffMember"
  belongs_to :mechanic, class_name: "StaffMember", optional: true
  belongs_to :returned_by_staff, class_name: "StaffMember", optional: true
  has_many :repair_jobs, dependent: :destroy, inverse_of: :repair
  has_many :services, through: :repair_jobs

  # Lab 9: the photos taken when the bike came in. Any number of them, as
  # rows in Active Storage's tables (repairs gets no column). Destroying a
  # repair deletes its attachment rows in the same transaction, and
  # dependent: :purge_later (Active Storage's default, written out here)
  # then purges each blob with its variants and files in a background job.
  # (:purge_later and false are the only values Active Storage acts on.)
  #
  # The two named variants are the only place their dimensions are written.
  # :thumb fills an exact square, cropping the longer side, so every
  # thumbnail in a list measures the same and none is stretched; :large is
  # shrunk to fit inside the box and keeps its proportions.
  THUMB_SIZE = 80 # px, square; also the size of the empty slot of a row without photos
  LARGE_SIZE = 1000 # px, the longest side at most

  has_many_attached :photos, dependent: :purge_later do |attachable|
    attachable.variant :thumb, resize_to_fill: [ THUMB_SIZE, THUMB_SIZE ]
    attachable.variant :large, resize_to_limit: [ LARGE_SIZE, LARGE_SIZE ]
  end

  # Lab 9: the mechanic's diagnosis, as rich text in action_text_rich_texts
  # (again no column on repairs). Optional, and removed with the repair.
  has_rich_text :diagnosis

  # What the shop's phones produce: JPEG and HEIC/HEIF (iPhone), PNG
  # (screenshots) and WebP (some Android cameras). Anything else (a PDF, a
  # video, an SVG) is refused. The type is the one Active Storage detects
  # from the file's own bytes, not the one the browser claims.
  PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp].freeze
  PHOTO_TYPES_IN_WORDS = "JPEG, PNG, HEIC or WebP"
  # A full-resolution phone photo is 2–8 MB; 10 MB leaves room for that and
  # still stops a video or an uncompressed camera file.
  PHOTO_MAX_SIZE = 10.megabytes

  enum :status, {
    dropped_off: "dropped_off",
    diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval",
    in_progress: "in_progress",
    declined_pickup_pending: "declined_pickup_pending",
    ready_for_pickup: "ready_for_pickup",
    picked_up: "picked_up"
  }, validate: { allow_nil: true }

  # Lab 8: a repair's lines are written through the repair's own form, in
  # the same save and the same transaction. A line whose service is left
  # blank is one of the spare empty lines and is ignored; an existing line
  # can be removed by ticking its "Remove" box (_destroy).
  accepts_nested_attributes_for :repair_jobs,
    allow_destroy: true,
    reject_if: ->(attributes) { attributes["service_id"].blank? }

  before_validation :take_customer_from_bike

  validates :status, presence: true

  validate :promised_and_returned_not_before_drop_off
  validate :answer_recorded_for_states_after_quote
  validate :photos_are_images_within_size_limit

  scope :newest_first, -> { order(created_at: :desc) }
  scope :open, -> { where(returned_at: nil) }
  scope :overdue, -> { open.where("promised_on < ?", Date.current) }

  # Mirrors the "Derived, or stored?" decision in docs/domain-model.md:
  # overdue is never a column, it's promised_on in the past on a repair
  # that hasn't come back yet.
  def overdue?
    promised_on.present? && promised_on < Date.current && returned_at.nil?
  end

  def total
    repair_jobs.sum(&:price_charged)
  end

  private

  # The form asks for the bike, not the customer: the customer who brings a
  # repair in is the bike's owner at that moment. repairs.customer_id keeps
  # that snapshot, so later changes of owner don't rewrite old repairs. It
  # is only recomputed when a new repair has none, or when the bike of an
  # existing repair is changed.
  def take_customer_from_bike
    return if bike.nil?

    if new_record? ? customer.nil? : will_save_change_to_bike_id?
      self.customer = bike.customer
    end
  end

  def promised_and_returned_not_before_drop_off
    # A repair being created right now has no created_at yet: its drop-off
    # day is today. (Before Lab 8 this check was skipped on create, which
    # let the new form save a promised day in the past.)
    drop_off_day = (created_at || Time.current).to_date

    if promised_on.present? && promised_on < drop_off_day
      errors.add(:promised_on, "cannot be before the day the bike was dropped off")
    end

    if returned_at.present? && returned_at.to_date < drop_off_day
      errors.add(:returned_at, "cannot be before the day the bike was dropped off")
    end
  end

  # One message per refused file, naming it. These are model validations,
  # so they hold for any request, with or without the form's file picker.
  # As with any failed save, nothing of a refused request is attached.
  def photos_are_images_within_size_limit
    photos.each do |photo|
      blob = photo.blob

      unless blob.content_type.in?(PHOTO_CONTENT_TYPES)
        errors.add(:photos, "“#{blob.filename}” is not a #{PHOTO_TYPES_IN_WORDS} image")
      end

      if blob.byte_size > PHOTO_MAX_SIZE
        errors.add(:photos, "“#{blob.filename}” is larger than the #{PHOTO_MAX_SIZE / 1.megabyte} MB limit")
      end
    end
  end

  def answer_recorded_for_states_after_quote
    if returned_at.present? && !picked_up?
      errors.add(:returned_at, "cannot be set unless the repair has been picked up")
    end

    if (in_progress? || declined_pickup_pending?) && quoted_at.blank?
      errors.add(:quoted_at, "must be recorded once the customer has answered the quote")
    end
  end
end

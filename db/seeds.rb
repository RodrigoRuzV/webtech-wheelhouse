# db/seeds.rb
#
# Wheelhouse seed data.
#
# Lab 6 adds belongs_to/has_many associations, but still no validations
# or scopes, so every relationship below is set through its own `_id`
# attribute rather than an association shorthand.
#
# Idempotent: the six tables this file owns are cleared before being
# rebuilt, and so are the tables of Active Storage (attachments, variant
# records, blobs and their files in storage/) and of Action Text (Lab 9),
# so running `bin/rails db:seed` twice leaves the same number of rows
# behind in every table. Every write uses a bang method, so a failed insert raises
# instead of silently leaving fewer rows than intended. Every date and
# time is written relative to `Time.current` / `Date.current`, so a
# repair that is overdue today is still overdue whenever this runs again.

ActiveRecord::Base.transaction do
  # Lab 9: the rich texts and the files go first. delete_all skips
  # callbacks, so nothing would remove them along with the repairs. The
  # attachments and variant records are deleted before the blobs (their
  # foreign keys point to them); each blob is purged so its file and its
  # variants' files leave storage/ too.
  ActionText::RichText.delete_all
  ActiveStorage::Attachment.delete_all
  ActiveStorage::VariantRecord.delete_all
  ActiveStorage::Blob.find_each(&:purge)

  RepairJob.delete_all
  Repair.delete_all
  Bike.delete_all
  Service.delete_all
  StaffMember.delete_all
  Customer.delete_all

  # ---------------------------------------------------------------------
  # Services — the wall list. The 14 from Lab 4's controller come first
  # (same names, same prices), with more added to comfortably clear 20.
  # ---------------------------------------------------------------------
  service_rows = [
    { name: "Tune-up",                      price: 45 },
    { name: "Brake adjustment",             price: 25 },
    { name: "Brake pad replacement",        price: 35 },
    { name: "Brake bleed",                  price: 40 },
    { name: "Chain replacement",            price: 30 },
    { name: "Cable replacement",            price: 20 },
    { name: "Flat tire repair",             price: 15 },
    { name: "Tire replacement",             price: 25 },
    { name: "Wheel truing",                 price: 30 },
    { name: "Spoke replacement",            price: 12 },
    { name: "Gear tuning",                  price: 25 },
    { name: "Bearing service",              price: 35 },
    { name: "Frame alignment check",        price: 40 },
    { name: "Full overhaul",                price: 120 },
    { name: "Disc brake rotor replacement", price: 28 },
    { name: "Headset adjustment",           price: 22 },
    { name: "Bottom bracket overhaul",      price: 45 },
    { name: "Handlebar tape replacement",   price: 18 },
    { name: "Saddle replacement",           price: 25 },
    { name: "Pedal replacement",            price: 20 },
    { name: "Kickstand installation",       price: 10 },
    { name: "Rear rack installation",       price: 15 },
    { name: "Fender installation",          price: 12 },
    { name: "Suspension fork service",      price: 65 },
    { name: "E-bike battery diagnostic",    price: 30 },
    { name: "Custom wheel build",           price: 150 }
  ]

  services = service_rows.each_with_object({}) do |row, memo|
    memo[row[:name]] = Service.create!(name: row[:name], price: row[:price])
  end

  # ---------------------------------------------------------------------
  # Staff — three mechanics, the person at the counter, and the owner.
  # ---------------------------------------------------------------------
  diego     = StaffMember.create!(name: "Diego Fuentes",   role: "mechanic")
  camila    = StaffMember.create!(name: "Camila Rojas",    role: "mechanic")
  martin    = StaffMember.create!(name: "Martín Soto",     role: "mechanic")
  valentina = StaffMember.create!(name: "Valentina Muñoz", role: "receptionist")
  roberto   = StaffMember.create!(name: "Roberto Ibáñez",  role: "owner")

  # ---------------------------------------------------------------------
  # Customers — at least ten. Benjamín gets no repairs at all.
  # ---------------------------------------------------------------------
  ana       = Customer.create!(name: "Ana Pérez",         phone: "+56 9 5123 4567")
  javier    = Customer.create!(name: "Javier Torres",     phone: "+56 9 5234 5678")
  camila_v  = Customer.create!(name: "Camila Vidal",      phone: "+56 9 5345 6789")
  francisco = Customer.create!(name: "Francisco Reyes",   phone: "+56 9 5456 7890")
  daniela   = Customer.create!(name: "Daniela Contreras", phone: "+56 9 5567 8901")
  matias    = Customer.create!(name: "Matías Herrera",    phone: "+56 9 5678 9012")
  sofia     = Customer.create!(name: "Sofía Navarro",     phone: "+56 9 5789 0123")
  cristobal = Customer.create!(name: "Cristóbal Silva",   phone: "+56 9 5890 1234")
  isidora   = Customer.create!(name: "Isidora Muñoz",     phone: "+56 9 5901 2345")
  benjamin  = Customer.create!(name: "Benjamín Castro",   phone: "+56 9 5012 3456") # no repairs

  # ---------------------------------------------------------------------
  # Bikes — at least twelve. bike_1 and bike_2 are the same make and
  # model, told apart only by serial_number (the "March mix-up", Lab 3).
  # ---------------------------------------------------------------------
  # Owners are assigned to match the repairs below one-for-one (no bike
  # is dropped off by two different customers), and mirror the Lab 3
  # assumption that a bike has exactly one owner over its life in the
  # system. Ana and Javier each own two bikes.
  bike_1  = Bike.create!(make: "Trek",        model: "Marlin 5",     serial_number: "WH-10234", customer_id: ana.id)
  bike_2  = Bike.create!(make: "Trek",        model: "Marlin 5",     serial_number: "WH-10567", customer_id: javier.id)
  bike_3  = Bike.create!(make: "Giant",       model: "Escape 3",     serial_number: "WH-20456", customer_id: camila_v.id)
  bike_4  = Bike.create!(make: "Specialized", model: "Allez",        serial_number: "WH-20789", customer_id: ana.id)
  bike_5  = Bike.create!(make: "Cannondale",  model: "Quick CX",     serial_number: "WH-21001", customer_id: francisco.id)
  bike_6  = Bike.create!(make: "Santa Cruz",  model: "Chameleon",    serial_number: "WH-21334", customer_id: daniela.id)
  bike_7  = Bike.create!(make: "Bianchi",     model: "Via Nirone 7", serial_number: "WH-21678", customer_id: matias.id)
  bike_8  = Bike.create!(make: "Scott",       model: "Aspect 950",   serial_number: "WH-22004", customer_id: sofia.id)
  bike_9  = Bike.create!(make: "Cervelo",     model: "R5",           serial_number: "WH-22315", customer_id: cristobal.id)
  bike_10 = Bike.create!(make: "Giant",       model: "Talon 3",      serial_number: "WH-22689", customer_id: isidora.id)
  bike_11 = Bike.create!(make: "Trek",        model: "FX 3",         serial_number: "WH-23012", customer_id: javier.id)
  bike_12 = Bike.create!(make: "Specialized", model: "Sirrus X",     serial_number: "WH-23345", customer_id: sofia.id)
  bike_13 = Bike.create!(make: "Cannondale",  model: "Trail 5",      serial_number: "WH-23678", customer_id: matias.id)

  # ---------------------------------------------------------------------
  # Repairs + the services charged on each. `add_jobs` charges today's
  # list price unless a specific price is given (used below for the
  # discount and the pre-January invoice).
  # ---------------------------------------------------------------------
  add_jobs = lambda do |repair, *entries|
    entries.each do |name, price|
      service = services.fetch(name)
      RepairJob.create!(
        repair_id: repair.id,
        service_id: service.id,
        price_charged: price || service.price
      )
    end
  end

  now = Time.current

  # R1 — just dropped off, nothing decided yet.
  r1 = Repair.create!(
    bike_id: bike_1.id, customer_id: ana.id, intake_staff_id: valentina.id,
    status: "dropped_off", created_at: now - 2.hours
  )
  add_jobs.call(r1, [ "Flat tire repair", nil ])

  # R2 — a mechanic is looking at it.
  r2 = Repair.create!(
    bike_id: bike_2.id, customer_id: javier.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "diagnosing", created_at: now - 2.days
  )
  add_jobs.call(r2, [ "Brake adjustment", nil ])

  # R3 — quoted, waiting on the customer.
  r3 = Repair.create!(
    bike_id: bike_3.id, customer_id: camila_v.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "awaiting_approval", created_at: now - 4.days,
    quoted_at: now - 2.days, promised_on: Date.current + 3.days
  )
  add_jobs.call(r3, [ "Bearing service", nil ], [ "Wheel truing", nil ])

  # R4 — approved and being worked on; one job discounted for a regular.
  r4 = Repair.create!(
    bike_id: bike_5.id, customer_id: francisco.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "in_progress", created_at: now - 6.days,
    quoted_at: now - 5.days, promised_on: Date.current + 1.day
  )
  add_jobs.call(r4, [ "Tune-up", nil ], [ "Chain replacement", 25 ], [ "Cable replacement", nil ])

  # R5 — quoted, customer said no.
  r5 = Repair.create!(
    bike_id: bike_8.id, customer_id: sofia.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "declined_pickup_pending", created_at: now - 5.days,
    quoted_at: now - 4.days, promised_on: Date.current - 1.day
  )
  add_jobs.call(r5, [ "Full overhaul", nil ])

  # R6 — quoted, approved, finished; waiting at the counter.
  r6 = Repair.create!(
    bike_id: bike_9.id, customer_id: cristobal.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "ready_for_pickup", created_at: now - 3.days,
    quoted_at: now - 2.days, promised_on: Date.current, finished_at: now - 6.hours
  )
  add_jobs.call(r6, [ "Brake pad replacement", nil ], [ "Gear tuning", nil ])

  # R7 — full lifecycle, already picked up.
  r7 = Repair.create!(
    bike_id: bike_10.id, customer_id: isidora.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "picked_up", created_at: now - 10.days,
    quoted_at: now - 9.days, promised_on: Date.current - 5.days,
    finished_at: now - 4.days, returned_at: now - 3.days, returned_by_staff_id: valentina.id
  )
  add_jobs.call(r7, [ "Chain replacement", nil ], [ "Tire replacement", nil ])

  # R8 — simple same-day job: no quote needed, dropped off and picked up today.
  r8 = Repair.create!(
    bike_id: bike_7.id, customer_id: matias.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "picked_up", created_at: now - 6.hours,
    finished_at: now - 3.hours, returned_at: now - 1.hour, returned_by_staff_id: valentina.id
  )
  add_jobs.call(r8, [ "Flat tire repair", nil ])

  # R9 — overdue: promised days ago, still in progress.
  r9 = Repair.create!(
    bike_id: bike_4.id, customer_id: ana.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "in_progress", created_at: now - 12.days,
    quoted_at: now - 11.days, promised_on: Date.current - 4.days
  )
  add_jobs.call(r9, [ "Frame alignment check", nil ], [ "Bearing service", nil ])

  # R10 — from before last January: charged less than today's list price.
  r10 = Repair.create!(
    bike_id: bike_6.id, customer_id: daniela.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "picked_up", created_at: now - 14.months,
    quoted_at: now - 14.months, promised_on: Date.current - 14.months + 3.days,
    finished_at: now - 14.months + 2.days, returned_at: now - 14.months + 3.days,
    returned_by_staff_id: valentina.id
  )
  add_jobs.call(r10, [ "Tune-up", 40 ])

  # R11 — the same bike, back again, much more recently.
  r11 = Repair.create!(
    bike_id: bike_6.id, customer_id: daniela.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "diagnosing", created_at: now - 1.day
  )
  add_jobs.call(r11, [ "Brake bleed", nil ])

  # R12 — another bike, just dropped off.
  r12 = Repair.create!(
    bike_id: bike_11.id, customer_id: javier.id, intake_staff_id: valentina.id,
    status: "dropped_off", created_at: now - 1.hour
  )
  add_jobs.call(r12, [ "Cable replacement", nil ])

  # R13 — being diagnosed.
  r13 = Repair.create!(
    bike_id: bike_12.id, customer_id: sofia.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "diagnosing", created_at: now - 1.day
  )
  add_jobs.call(r13, [ "Wheel truing", nil ])

  # R14 — quoted, waiting on the customer.
  r14 = Repair.create!(
    bike_id: bike_13.id, customer_id: matias.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "awaiting_approval", created_at: now - 3.days,
    quoted_at: now - 2.days, promised_on: Date.current + 2.days
  )
  add_jobs.call(r14, [ "Suspension fork service", nil ], [ "Disc brake rotor replacement", nil ])

  # R15 — simple job, finished, waiting at the counter.
  r15 = Repair.create!(
    bike_id: bike_10.id, customer_id: isidora.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "ready_for_pickup", created_at: now - 2.days,
    promised_on: Date.current, finished_at: now - 2.hours
  )
  add_jobs.call(r15, [ "Spoke replacement", nil ])

  # R16 — a second, brand-new repair on Camila's bike.
  r16 = Repair.create!(
    bike_id: bike_3.id, customer_id: camila_v.id, intake_staff_id: valentina.id,
    status: "dropped_off", created_at: now - 30.minutes
  )
  add_jobs.call(r16, [ "Headset adjustment", nil ])

  # R17 — an older, already-collected repair for Sofía.
  r17 = Repair.create!(
    bike_id: bike_8.id, customer_id: sofia.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "picked_up", created_at: now - 8.days,
    quoted_at: now - 7.days, promised_on: Date.current - 5.days,
    finished_at: now - 4.days, returned_at: now - 3.days, returned_by_staff_id: valentina.id
  )
  add_jobs.call(r17, [ "Bearing service", nil ])

  # ---------------------------------------------------------------------
  # Lab 9 — intake photos. The files are the seven photos committed in
  # db/seeds/ (bike-01.jpg … bike-07.jpg, from Unsplash, see the README).
  # The same file goes to several repairs, but every attachment gets a blob
  # of its own, so removing a photo from one repair removes its blob row
  # too and never touches another repair's photo.
  #
  # Every repair has photos except two: R8, a same-day flat fixed at the
  # counter, and R10, from before the shop took photos. R9, the overdue
  # frame check, has five.
  # ---------------------------------------------------------------------
  seed_photo = lambda do |number|
    filename = format("bike-%02d.jpg", number)
    { io: StringIO.new(File.binread(Rails.root.join("db/seeds", filename))),
      filename: filename, content_type: "image/jpeg" }
  end

  attach_photos = lambda do |repair, *numbers|
    repair.photos.attach(numbers.map { |number| seed_photo.call(number) })
  end

  attach_photos.call(r1,  1, 2)
  attach_photos.call(r2,  2)
  attach_photos.call(r3,  3, 4)
  attach_photos.call(r4,  4)
  attach_photos.call(r5,  5, 6)
  attach_photos.call(r6,  6)
  attach_photos.call(r7,  7)
  attach_photos.call(r9,  1, 3, 5, 7, 2) # five photos
  attach_photos.call(r11, 3)
  attach_photos.call(r12, 4, 5)
  attach_photos.call(r13, 5)
  attach_photos.call(r14, 6, 7)
  attach_photos.call(r15, 7)
  attach_photos.call(r16, 1)
  attach_photos.call(r17, 2, 3)

  # ---------------------------------------------------------------------
  # Lab 9 — diagnoses, as the HTML Trix writes (bold, lists, a link and a
  # quote here and there). The three repairs still in "dropped_off" (R1,
  # R12, R16) have just been taken in and have none.
  # ---------------------------------------------------------------------
  diagnoses = {
    r2 => <<~HTML,
      <div><strong>Rear brake rubbing.</strong> Caliper is off-centre and the pads are glazed.</div>
      <ul><li>Re-centre the rear caliper</li><li>Sand the pads, check rotor for warping</li></ul>
    HTML
    r3 => <<~HTML,
      <div><strong>Grinding from the front hub</strong> and a visible wobble in the rear wheel.</div>
      <ul><li>Front hub bearings worn — replace</li><li>Rear wheel 3 mm out of true</li></ul>
      <blockquote>Customer says the noise started after a rainy commute.</blockquote>
    HTML
    r4 => <<~HTML,
      <div><strong>General wear, approved in full.</strong></div>
      <ul><li>Chain stretched past 0.75 %</li><li>Shift cables frayed at the derailleur</li><li>Gears need indexing after the cable swap</li></ul>
    HTML
    r5 => <<~HTML,
      <div><strong>Needs a full overhaul</strong> — the customer declined the quote.</div>
      <ul><li>Bottom bracket loose</li><li>Headset pitted</li><li>Both wheels out of true</li></ul>
    HTML
    r6 => <<~HTML,
      <div><strong>Brakes squealing and skipping gears.</strong></div>
      <ol><li>Replace front and rear pads</li><li>Tune the rear derailleur</li></ol>
    HTML
    r7 => <<~HTML,
      <div><strong>Chain snapped on a climb</strong>; rear tyre worn to the casing.</div>
      <ul><li>New chain</li><li>New rear tyre</li></ul>
    HTML
    r8 => <<~HTML,
      <div><strong>Flat front tyre.</strong> Thorn in the tread, tube patched at the counter.</div>
      <ul><li>No other damage found</li></ul>
    HTML
    r9 => <<~HTML,
      <div><strong>Crash damage — check the frame before anything else.</strong></div>
      <ul><li>Down tube scraped, no cracks visible</li><li>Rear dropout possibly bent</li><li>Bottom bracket bearings rough</li></ul>
      <div>Waiting on the alignment gauge, see <a href="https://www.parktool.com/en-us/blog/repair-help">Park Tool's repair guide</a>.</div>
    HTML
    r10 => <<~HTML,
      <div><strong>Yearly tune-up.</strong></div>
      <ul><li>Adjust brakes and gears</li><li>Lube chain</li></ul>
    HTML
    r11 => <<~HTML,
      <div><strong>Spongy rear brake lever.</strong> Air in the hydraulic line.</div>
      <ul><li>Bleed the rear brake</li><li>Check the hose for leaks</li></ul>
    HTML
    r13 => <<~HTML,
      <div><strong>Rear wheel wobbles</strong> after hitting a pothole.</div>
      <ul><li>True the rear wheel</li><li>Check spoke tension all round</li></ul>
    HTML
    r14 => <<~HTML,
      <div><strong>Fork sticks</strong> and the front rotor is scored.</div>
      <ul><li>Service the suspension fork</li><li>Replace the front rotor</li></ul>
      <blockquote>Quote sent by phone, waiting on Matías.</blockquote>
    HTML
    r15 => <<~HTML,
      <div><strong>One broken spoke</strong> on the rear wheel, drive side.</div>
      <ul><li>Replace the spoke and re-true</li></ul>
    HTML
    r17 => <<~HTML
      <div><strong>Creaking under load.</strong></div>
      <ul><li>Bottom bracket bearings dry — regrease</li><li>Pedal threads checked, fine</li></ul>
    HTML
  }

  diagnoses.each { |repair, html| repair.update!(diagnosis: html) }
end

puts "Seeded #{Service.count} services, #{StaffMember.count} staff, " \
     "#{Customer.count} customers, #{Bike.count} bikes, " \
     "#{Repair.count} repairs, #{RepairJob.count} repair jobs, " \
     "#{ActiveStorage::Attachment.count} attachments, #{ActiveStorage::Blob.count} blobs, " \
     "#{ActiveStorage::VariantRecord.count} variant records, " \
     "#{ActionText::RichText.count} rich texts."

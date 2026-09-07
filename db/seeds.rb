# db/seeds.rb
#
# Wheelhouse seed data.
#
# Only the six plain models from Lab 5 exist (no associations, validations
# or scopes yet), so every relationship below is set through its own
# `_id` attribute rather than an association shorthand.
#
# Idempotent: the six tables this file owns are cleared before being
# rebuilt, so running `bin/rails db:seed` twice leaves the same number of
# rows behind. Every write uses a bang method, so a failed insert raises
# instead of silently leaving fewer rows than intended. Every date and
# time is written relative to `Time.current` / `Date.current`, so a
# repair that is overdue today is still overdue whenever this runs again.

ActiveRecord::Base.transaction do
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
  bike_1  = Bike.create!(make: "Trek",        model: "Marlin 5",     serial_number: "WH-10234")
  bike_2  = Bike.create!(make: "Trek",        model: "Marlin 5",     serial_number: "WH-10567")
  bike_3  = Bike.create!(make: "Giant",       model: "Escape 3",     serial_number: "WH-20456")
  bike_4  = Bike.create!(make: "Specialized", model: "Allez",        serial_number: "WH-20789")
  bike_5  = Bike.create!(make: "Cannondale",  model: "Quick CX",     serial_number: "WH-21001")
  bike_6  = Bike.create!(make: "Santa Cruz",  model: "Chameleon",    serial_number: "WH-21334")
  bike_7  = Bike.create!(make: "Bianchi",     model: "Via Nirone 7", serial_number: "WH-21678")
  bike_8  = Bike.create!(make: "Scott",       model: "Aspect 950",   serial_number: "WH-22004")
  bike_9  = Bike.create!(make: "Cervelo",     model: "R5",           serial_number: "WH-22315")
  bike_10 = Bike.create!(make: "Giant",       model: "Talon 3",      serial_number: "WH-22689")
  bike_11 = Bike.create!(make: "Trek",        model: "FX 3",         serial_number: "WH-23012")
  bike_12 = Bike.create!(make: "Specialized", model: "Sirrus X",     serial_number: "WH-23345")
  bike_13 = Bike.create!(make: "Cannondale",  model: "Trail 5",      serial_number: "WH-23678")

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
  add_jobs.call(r1, ["Flat tire repair", nil])

  # R2 — a mechanic is looking at it.
  r2 = Repair.create!(
    bike_id: bike_2.id, customer_id: javier.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "diagnosing", created_at: now - 2.days
  )
  add_jobs.call(r2, ["Brake adjustment", nil])

  # R3 — quoted, waiting on the customer.
  r3 = Repair.create!(
    bike_id: bike_3.id, customer_id: camila_v.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "awaiting_approval", created_at: now - 4.days,
    quoted_at: now - 2.days, promised_on: Date.current + 3.days
  )
  add_jobs.call(r3, ["Bearing service", nil], ["Wheel truing", nil])

  # R4 — approved and being worked on; one job discounted for a regular.
  r4 = Repair.create!(
    bike_id: bike_5.id, customer_id: francisco.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "in_progress", created_at: now - 6.days,
    quoted_at: now - 5.days, promised_on: Date.current + 1.day
  )
  add_jobs.call(r4, ["Tune-up", nil], ["Chain replacement", 25], ["Cable replacement", nil])

  # R5 — quoted, customer said no.
  r5 = Repair.create!(
    bike_id: bike_8.id, customer_id: sofia.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "declined_pickup_pending", created_at: now - 5.days,
    quoted_at: now - 4.days, promised_on: Date.current - 1.day
  )
  add_jobs.call(r5, ["Full overhaul", nil])

  # R6 — quoted, approved, finished; waiting at the counter.
  r6 = Repair.create!(
    bike_id: bike_9.id, customer_id: cristobal.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "ready_for_pickup", created_at: now - 3.days,
    quoted_at: now - 2.days, promised_on: Date.current, finished_at: now - 6.hours
  )
  add_jobs.call(r6, ["Brake pad replacement", nil], ["Gear tuning", nil])

  # R7 — full lifecycle, already picked up.
  r7 = Repair.create!(
    bike_id: bike_10.id, customer_id: isidora.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "picked_up", created_at: now - 10.days,
    quoted_at: now - 9.days, promised_on: Date.current - 5.days,
    finished_at: now - 4.days, returned_at: now - 3.days, returned_by_staff_id: valentina.id
  )
  add_jobs.call(r7, ["Chain replacement", nil], ["Tire replacement", nil])

  # R8 — simple same-day job: no quote needed, dropped off and picked up today.
  r8 = Repair.create!(
    bike_id: bike_7.id, customer_id: matias.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "picked_up", created_at: now - 6.hours,
    finished_at: now - 3.hours, returned_at: now - 1.hour, returned_by_staff_id: valentina.id
  )
  add_jobs.call(r8, ["Flat tire repair", nil])

  # R9 — overdue: promised days ago, still in progress.
  r9 = Repair.create!(
    bike_id: bike_4.id, customer_id: ana.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "in_progress", created_at: now - 12.days,
    quoted_at: now - 11.days, promised_on: Date.current - 4.days
  )
  add_jobs.call(r9, ["Frame alignment check", nil], ["Bearing service", nil])

  # R10 — from before last January: charged less than today's list price.
  r10 = Repair.create!(
    bike_id: bike_6.id, customer_id: daniela.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "picked_up", created_at: now - 14.months,
    quoted_at: now - 14.months, promised_on: Date.current - 14.months + 3.days,
    finished_at: now - 14.months + 2.days, returned_at: now - 14.months + 3.days,
    returned_by_staff_id: valentina.id
  )
  add_jobs.call(r10, ["Tune-up", 40])

  # R11 — the same bike, back again, much more recently.
  r11 = Repair.create!(
    bike_id: bike_6.id, customer_id: daniela.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "diagnosing", created_at: now - 1.day
  )
  add_jobs.call(r11, ["Brake bleed", nil])

  # R12 — another bike, just dropped off.
  r12 = Repair.create!(
    bike_id: bike_11.id, customer_id: javier.id, intake_staff_id: valentina.id,
    status: "dropped_off", created_at: now - 1.hour
  )
  add_jobs.call(r12, ["Cable replacement", nil])

  # R13 — being diagnosed.
  r13 = Repair.create!(
    bike_id: bike_12.id, customer_id: sofia.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "diagnosing", created_at: now - 1.day
  )
  add_jobs.call(r13, ["Wheel truing", nil])

  # R14 — quoted, waiting on the customer.
  r14 = Repair.create!(
    bike_id: bike_13.id, customer_id: matias.id, intake_staff_id: valentina.id,
    mechanic_id: martin.id, status: "awaiting_approval", created_at: now - 3.days,
    quoted_at: now - 2.days, promised_on: Date.current + 2.days
  )
  add_jobs.call(r14, ["Suspension fork service", nil], ["Disc brake rotor replacement", nil])

  # R15 — simple job, finished, waiting at the counter.
  r15 = Repair.create!(
    bike_id: bike_10.id, customer_id: isidora.id, intake_staff_id: valentina.id,
    mechanic_id: camila.id, status: "ready_for_pickup", created_at: now - 2.days,
    promised_on: Date.current, finished_at: now - 2.hours
  )
  add_jobs.call(r15, ["Spoke replacement", nil])

  # R16 — a second, brand-new repair on Camila's bike.
  r16 = Repair.create!(
    bike_id: bike_3.id, customer_id: camila_v.id, intake_staff_id: valentina.id,
    status: "dropped_off", created_at: now - 30.minutes
  )
  add_jobs.call(r16, ["Headset adjustment", nil])

  # R17 — an older, already-collected repair for Sofía.
  r17 = Repair.create!(
    bike_id: bike_8.id, customer_id: sofia.id, intake_staff_id: valentina.id,
    mechanic_id: diego.id, status: "picked_up", created_at: now - 8.days,
    quoted_at: now - 7.days, promised_on: Date.current - 5.days,
    finished_at: now - 4.days, returned_at: now - 3.days, returned_by_staff_id: valentina.id
  )
  add_jobs.call(r17, ["Bearing service", nil])
end

puts "Seeded #{Service.count} services, #{StaffMember.count} staff, " \
     "#{Customer.count} customers, #{Bike.count} bikes, " \
     "#{Repair.count} repairs, #{RepairJob.count} repair jobs."

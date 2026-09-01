# Domain Model

## Diagram

![Wheelhouse domain model](images/dbdiagram.png)

## DBML

```dbml
Table customers {
  id integer [pk, increment]
  name varchar [not null]
  phone varchar [not null]
}

Table staff_members {
  id integer [pk, increment]
  name varchar [not null]
  role staff_role [not null]
}

enum staff_role {
  mechanic
  receptionist
  owner
}

Table bikes {
  id integer [pk, increment]
  make varchar [not null]
  model varchar [not null]
  serial_number varchar [not null, unique, note: 'prevents the March mix-up: identifies the physical bike, not just make+model+colour']
}

Table job_catalog {
  id integer [pk, increment]
  name varchar [not null, unique]
  price decimal [not null, note: 'current wall-list price; changes each January']
}

Table repairs {
  id integer [pk, increment]
  bike_id integer [ref: > bikes.id, not null]
  customer_id integer [ref: > customers.id, not null, note: 'the customer who dropped the bike off this time']
  intake_staff_id integer [ref: > staff_members.id, not null]
  mechanic_id integer [ref: > staff_members.id, note: 'assigned once diagnosis starts']
  diagnosis text [note: 'free text: paragraph or list']
  promised_date date
  status repair_status [not null, default: 'dropped_off']
  quoted_at datetime
  finished_at datetime
  returned_at datetime
  returned_by_staff_id integer [ref: > staff_members.id]
  created_at datetime [not null, default: `now()`]
}

enum repair_status {
  dropped_off
  diagnosing
  awaiting_approval
  in_progress
  declined_pickup_pending
  ready_for_pickup
  picked_up
}

Table repair_jobs {
  id integer [pk, increment]
  repair_id integer [ref: > repairs.id, not null]
  job_catalog_id integer [ref: > job_catalog.id, not null]
  price_charged decimal [not null, note: 'snapshot of the price at the time of this repair — never recalculated from job_catalog.price']
}

Table photos {
  id integer [pk, increment]
  repair_id integer [ref: > repairs.id, not null]
  image_url varchar [not null]
}
```

## Lifecycle

`repairs.status` is the lifecycle of a single repair, from the bike arriving to the bike leaving.

**Allowed transitions:**

- `dropped_off` → `diagnosing` — the mechanic starts looking at the bike.
- `diagnosing` → `ready_for_pickup` — shortcut for a simple same-day job (e.g. a flat tyre), no quote needed (user story 5).
- `diagnosing` → `awaiting_approval` — a bigger job: the customer is called with a price (user story 6.1).
- `awaiting_approval` → `in_progress` — the customer approves the quote (user story 6.2).
- `awaiting_approval` → `declined_pickup_pending` — the customer declines the quote (user story 6.2 / 10).
- `in_progress` → `ready_for_pickup` — the mechanic finishes the approved jobs (user story 8).
- `ready_for_pickup` → `picked_up` (user story 9 / 10).
- `declined_pickup_pending` → `picked_up` — no work was performed (user story 10).

**Transitions that are explicitly not allowed:**

- `dropped_off` → `ready_for_pickup`. A bike cannot skip diagnosis.
- `awaiting_approval` → `ready_for_pickup` or `awaiting_approval` → `in_progress` without the customer's decision being recorded. Work cannot start or finish on an unapproved quote.
- `declined_pickup_pending` → `in_progress`. Once a customer has declined, the shop cannot resume work without a new quote-and-approval cycle (a fresh pass through `diagnosing` → `awaiting_approval`).
- `picked_up` → any other state. `picked_up` is terminal — a bike that comes back for a new problem gets a new `repairs` row, it does not reopen the old one.

## Every entity traces back to a story

| Entity | Required by |
|---|---|
| `customers` | User story 1 — a customer's name and phone are recorded and tied to the bike at drop-off |
| `staff_members` | User story 8 — a mechanic records which jobs *they* performed; each of the three mechanics is a distinct actor, not an anonymous "staff" flag |
| `bikes` | User story 2 — make, model and serial number, kept as one row per physical bike |
| `job_catalog` | User story 15 — the wall list of jobs and prices, published on the website |
| `repairs` | User story 1 — created the moment a bike is dropped off; carries diagnosis, promised date and status through the rest of the stories |
| `repair_jobs` | User story 8 — the specific jobs applied to one repair, at the price actually charged |
| `photos` | User story 3 — photos taken of the bike when it arrives |

## Two decisions

**The thing and the copy of the thing.** `bikes` has no quantity column and no "model" table shared across physical bikes — every bike is its own row, identified by a unique `serial_number`. That is exactly what prevents the mix-up from March: a table like `bike_models { make, model, colour, quantity }` can tell you the shop has handled two blue Trek Marlins, but it cannot tell you which specific one is on the rack, which one belongs to which ticket, or which one had its fork replaced last year — the individual bike has a history, so it has to be an entity, not a count.

**Derived, or stored?** Whether a repair is overdue is never stored: it's computed as `promised_date < today AND status not in (ready_for_pickup, picked_up)`, exactly like the owner's "call them before they call me" list. Storing an `overdue` flag would let it go stale the moment midnight passes without anyone touching the row. What we do store, even though it looks derivable, is `repair_jobs.price_charged`. It looks like it should just be `job_catalog.price` at read time — but `job_catalog.price` changes every January, and it is not versioned. If we didn't snapshot the price into `repair_jobs`, every invoice from last year would silently reprice itself the day the wall list changes, and there would be no way to represent a discount given to a regular customer at all.
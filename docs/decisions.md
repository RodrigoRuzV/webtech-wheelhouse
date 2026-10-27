# Decisions

Three questions I would ask the owner if the owner were in the room — chosen because the answer changes the model.

## 1. Can more than one mechanic work on the same bike, or does one mechanic own a repair from diagnosis to completion?

**Assumption made:** one mechanic per repair. `repairs.mechanic_id` is a single foreign key to `staff_members`.

**What would change if the answer is the other one:** if several mechanics can each perform different jobs on the same bike, `mechanic_id` would have to move from `repairs` down to `repair_jobs` — one mechanic per job line, not one mechanic per repair.

## 2. Is every job that gets charged always one from the wall list, or does the shop sometimes charge for something that isn't on it?

**Assumption made:** the price list is a closed set. Every row in `repair_jobs` points to a `job_catalog` entry; there is no free-text job.

**What would change if the answer is the other one:** `repair_jobs.job_catalog_id` would need to become optional, and `repair_jobs` would need its own `description` and `price` columns for the case where there is no catalog entry to point to.

## 3. When a bike is resold, does the shop find out and record it, or is "the current owner" just whoever last dropped the bike off?

**Assumption made:** there is no formal ownership transfer. As of Lab 6, `bikes.customer_id` stores that single current owner directly, rather than inferring it by reading the `customer_id` off the bike's most recent `repair` (the Lab 3 approach). The assumption about the world hasn't changed — a bike still has exactly one owner for its life in the system, and a sale isn't a modelled event — only where that fact lives changed, from computed at read time to stored on the row.

**What would change if the answer is the other one:** if the shop wants a real record of ownership changes over time (for example, to know who owned the bike during a specific past repair, independent of who owns it today), a `bike_owners` join entity would be needed, with `bike_id`, `customer_id`, and a start/end date range — ownership would stop being a single stored value and become a stored history.

---

# Lab 11 decisions

## 4. Which role does a new account get?

**Decision:** `mechanic`. The column `users.role` defaults to it, and the sign-up page can't choose another one.

**Why:** the default has to be the role with the fewest permissions, since anyone who reaches the sign-up page gets it. Of the three people of the workshop, the mechanic needs the least:

- **Owner** — everything: the price list, the staff, every repair and the overdue list.
- **Counter** — takes bikes in and hands them back, records the customers (names and phone numbers), calls them with the quote and takes the payment. It handles the customers' personal data and the money.
- **Mechanic** — works on the bikes already taken in: the diagnosis, the jobs and their prices on a repair. A mechanic never needs to register a customer, change the price list or manage the staff.

So an account that nobody has looked at yet starts as a mechanic, and the owner promotes it from the console or the seed (`counter` or `owner`) once they know who it is. Lab 11 doesn't restrict any page by role yet; when it does, this default is the one that opens the least.

## 5. What happens to `repairs.intake_staff_id` now that the account is recorded?

**Decision:** the select "Taken in by" leaves the repair's form, and `intake_staff_id` leaves the permitted list. The column stays, allows `NULL`, and a new repair fills it from the account's member of the staff. The new `intake_user_id` is what the repair's page shows as "Taken in by".

**Why:** with both a select and the session, a repair could say it was taken in by one person while the account at the keyboard was another's. The session is the one that can't be written by hand, so it wins. Dropping the column instead would erase who took in the repairs from before accounts; keeping it nullable keeps that history (shown as "before accounts") and keeps each member's list of intake repairs working.


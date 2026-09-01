# Decisions

Three questions I would ask the owner if the owner were in the room — chosen because the answer changes the model.

## 1. Can more than one mechanic work on the same bike, or does one mechanic own a repair from diagnosis to completion?

**Assumption made:** one mechanic per repair. `repairs.mechanic_id` is a single foreign key to `staff_members`.

**What would change if the answer is the other one:** if several mechanics can each perform different jobs on the same bike, `mechanic_id` would have to move from `repairs` down to `repair_jobs` — one mechanic per job line, not one mechanic per repair.

## 2. Is every job that gets charged always one from the wall list, or does the shop sometimes charge for something that isn't on it?

**Assumption made:** the price list is a closed set. Every row in `repair_jobs` points to a `job_catalog` entry; there is no free-text job.

**What would change if the answer is the other one:** `repair_jobs.job_catalog_id` would need to become optional, and `repair_jobs` would need its own `description` and `price` columns for the case where there is no catalog entry to point to.

## 3. When a bike is resold, does the shop find out and record it, or is "the current owner" just whoever last dropped the bike off?

**Assumption made:** there is no formal ownership transfer. The current owner of a bike is inferred as the `customer_id` on its most recent `repair` — nothing is stored on `bikes` itself.

**What would change if the answer is the other one:** if the shop wants a real record of ownership changes (for example, to know who owned the bike during a specific past repair, independent of who happens to bring it in later), a `bike_owners` join entity would be needed, with `bike_id`, `customer_id`, and a start/end date range — ownership would stop being something inferred and become something stored.
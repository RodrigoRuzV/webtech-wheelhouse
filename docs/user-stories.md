# Roles

1. Mechanic
2. Receptionist
3. Owner
4. Customer

# User stories

1. As a [receptionist], I want to [write down a customer's name and phone number and attach them to a bike when it is dropped off], so that [the bike can always be matched back to its owner].
2. As a [mechanic], I want to [record a bike's make, model and serial number when it arrives], so that [it is never confused with another bike of the same make and colour].
3. As a [receptionist], I want to [photograph a bike when it arrives], so that [nobody can dispute later who caused an existing scratch].
4. As a [mechanic], I want to [write a diagnosis as free text after inspecting a bike], so that [another mechanic or the owner can understand what is wrong without asking me directly].
5. As a [mechanic], I want to [complete a simple same-day job, like a flat tyre, without waiting for a phone quote], so that [quick fixes aren't delayed by the approval process used for bigger jobs].
6. As a [customer], I want to [get my bike fixed], so that [I can ride it again]. — *This bundles drop-off, diagnosis, quoting, approval and pickup into a single story. Nobody can build or test "get my bike fixed" as one unit — it's four different decisions with four different owners in the workflow. Split by value below:*
    - 6.1. As a [customer], I want to [receive a call with a price quote before any work beyond a simple same-day fix begins], so that [I can decide whether to approve the repair].
    - 6.2. As a [customer], I want to [approve or decline a quoted repair], so that [the shop only does work I've agreed to pay for].
    - 6.3. As a [customer], I want to [be notified when my bike is ready for pickup], so that [I don't have to keep calling the shop to check].
7. As a [customer], I want to [pick up my bike as it arrived if I decline the quoted work], so that [I'm not charged for repairs I never approved].
8. As a [mechanic], I want to [record which jobs I performed on a bike and mark it as finished], so that [the front desk can tell the customer it is ready].
9. As a [receptionist], I want to [check whether a specific bike is ready for pickup], so that [I can answer a customer's phone call without walking to the back to ask a mechanic].
10. As a [receptionist], I want to [hand a bike back to its owner and mark it as returned], so that [the shop's records reflect that the repair is closed].
11. As a [mechanic], I want to [see a bike's full repair history across all of its previous owners], so that [I know what work has already been done to it before I touch it again].
12. As an [owner], I want to [see the list of bikes whose promised day has passed and that are not yet finished], so that [I can call the customer before they call me].
13. As an [owner], I want to [update the price list every January], so that [new invoices use the new prices while last year's invoices stay unchanged].
14. As an [owner], I want to [charge less than the list price for a specific job on a specific bike], so that [I can offer a discount to a regular customer or reflect that the job was easier than expected].
15. As a [customer], I want to [see the shop's price list on the website], so that [I know what a tune-up costs without calling the shop].

# Acceptance criteria

**User story 2** — Record a bike's make, model and serial number

1. A bike cannot be saved without a serial number.
2. Two bikes of the same make, model and colour are distinguishable in the system by their serial number.
3. Saving a serial number that already exists in the system shows a warning before it's confirmed.

**User story 6.2** — Approve or decline a quoted repair

1. A repair cannot be approved or declined until the customer has actually been given a price.
2. Declining sets the bike to "ready for pickup as-is," and no further work can be logged against it.
3. Approving unlocks the ability for a mechanic to record jobs performed on that bike.

**User story 9** — Check whether a bike is ready for pickup

1. Searching by customer name or phone shows every bike currently at the shop for that customer, with its status.
2. Each bike's status clearly shows whether it's finished/ready for pickup or still in progress.
3. A bike that has already been picked up no longer appears in the "at the shop" list, but its record still exists as history.

**User story 12** — Overdue bikes list

1. A bike appears on the list only when today is after its promised day and it is not yet finished.
2. The list is sorted with the most overdue bike first.
3. Each row shows the bike, the customer and how many days overdue it is.
4. If there are no overdue bikes, the screen says so explicitly, instead of showing an empty list.
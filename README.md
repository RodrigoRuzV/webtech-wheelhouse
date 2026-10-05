# Wheelhouse

Wheelhouse is the system for a neighbourhood bicycle repair shop. It replaces the paper tag tied to the handlebars and the mechanics' individual notebooks with one shared record of a bike's repair — from the moment it's dropped off to the moment it leaves.

## Who uses it

- **Receptionist** — records a bike at intake, and answers "is this bike ready?" at the counter without walking to the back of the shop.
- **Mechanic** — diagnoses a bike, records the jobs performed and their price, and can see a bike's full repair history across its previous owners.
- **Owner** — sees which repairs have passed their promised day, and keeps the price list current.
- **Customer** — checks the shop's price list on the public website, without calling to ask.

## Running the app

### Prerequisites

- Ruby 4.0.6
- Rails 8.1.3.1
- PostgreSQL 16, running locally, with a role that can create databases. `config/database.yml` doesn't set a username, so it connects as whichever OS user runs Rails — if that role can't create databases yet, run `createuser -s $(whoami)` first.
- Node.js and Yarn (used to compile Bootstrap's CSS)
- **libvips**, the image library Active Storage uses to make the thumbnails of the intake photos (through the `image_processing` gem). Without it every page with photos shows broken images. Install it with:
  - macOS (Homebrew): `brew install vips`
  - Ubuntu / Debian: `sudo apt install libvips42`
  - Others: see [libvips.org/install](https://www.libvips.org/install.html)

  Check it with `vips --version` (tested with 8.18).

### Setup

    bundle install
    bin/rails db:prepare
    yarn install

`db:prepare` creates the development and test databases if they don't exist, runs every migration in `db/migrate/` (including the tables of Active Storage and Action Text), and — the first time, on a fresh clone — loads `db/seeds.rb` automatically. A fresh clone ends up with a full workshop's worth of data (services, staff, customers, bikes, and repairs across every stage of the repair lifecycle, with their intake photos and diagnoses) with no separate seeding step. The seed's photos are copied into `storage/`, which git ignores: no uploaded file is ever committed. To reseed later without a fresh database, run `bin/rails db:seed` directly — it's safe to run more than once.

### Start the server

    bin/dev

This starts Puma and the CSS watcher together (the watcher compiles the CSS once when it starts). Visit http://localhost:3000/repairs: every row shows the thumbnail of an intake photo and the beginning of the diagnosis. The first visit takes a moment while the thumbnails are generated; after that they are served from `storage/`. Use the navbar — Customers, Bikes, Repairs, Services and Staff each have a list page and a page per record, all read live from the database, so editing `db/seeds.rb` and reseeding changes what every page shows.

Every `_id` column in the schema is a real foreign key, enforced by PostgreSQL, and every model declares its side of the association that column stands for (`belongs_to` / `has_many`, plus the `has_many :through` associations added in Lab 7). As of Lab 7, every model also validates its data (presence, uniqueness and numericality where the schema calls for it, plus two custom validations on `Repair`), every `has_many` declares how its children behave when the parent is destroyed, `repairs.status` is a proper `enum`, every list is ordered through a named scope, and every `index`/`show` eager-loads what it renders so the number of queries doesn't grow with the number of rows. Customers, bikes, repairs, services and staff each have a hand-written controller with the seven RESTful actions, wired through `resources`; the join between a repair and a service (`repair_jobs`) has no routes of its own.

### Writing from the browser (Lab 8)

Every record can be created, edited and deleted from the browser:

- **One form per resource** (`app/views/<resource>/_form.html.erb`), built with `form_with` bound to the record and shared by `new` and `edit`. Every `belongs_to` is a select that shows the parent by name; a repair's state is a select built from the enum, and so is a staff member's role.
- **Strong parameters**: each controller has one private `<resource>_params` method using `params.expect`. A request with no key for the resource answers `400 Bad Request`.
- **A repair's form writes two tables** in one save through `accepts_nested_attributes_for :repair_jobs`: each line picks a service and the price charged that day. It works without JavaScript — a new repair offers 3 empty lines and every edit adds 2 more (save and edit again to add more); a line left without a service is ignored, and an existing line is removed with its "Remove this line" box. The repair's customer isn't asked for: it's taken from the bike's owner.
- **After a valid write** the app redirects to the record (or to the index after a delete) with a flash message naming it, drawn once by the layout.
- **After a refused write** the same form is rendered again with status `422`, the typed values kept, a summary of every error at the top and each invalid field marked with Bootstrap's `is-invalid` state. Rails' `field_with_errors` wrapper is turned off in `config/initializers/field_error_proc.rb`.
- **Deleting** is a button on every record's page that asks for confirmation first. A customer who owns a bike, a service already charged on a repair, a bike with repairs and a staff member with repairs refuse to be deleted, and the page says why.
- Bikes can be added from a customer's page and repairs taken in from a bike's page, with the parent already chosen.

### Intake photos and the diagnosis (Lab 9)

A repair carries the photos taken when the bike came in and the mechanic's diagnosis, as formatted text. Neither is a column of `repairs`: the photos live in Active Storage's tables and the diagnosis in Action Text's.

- **Photos** (`has_many_attached :photos` on `Repair`) are chosen in the repair's form, several at once. On edit, the files chosen are **added** to the photos the repair has (the form sends the existing ones back as hidden signed ids); saving without choosing a file leaves them as they were.
- **Accepted files:** JPEG, PNG, HEIC/HEIF and WebP — what the shop's phones and screenshots produce — up to **10 MB** each. Both rules are validations on `Repair`, checked against the type Active Storage detects from the file's bytes (not its name or the browser's claim). A refused upload answers `422`, names the file under the field, and attaches **none** of the files sent with it.
- **Removing a photo**: each photo on the repair's page and on its edit page has a *Remove* button (a `DELETE` with a confirmation). It purges that photo's attachment and blob and leaves the others. Destroying a repair purges its photos and deletes its diagnosis.
- **Thumbnails**: two named variants, declared in `app/models/repair.rb` and nowhere else — `:thumb`, an 80 × 80 square crop for the rows of every list of repairs, and `:large`, at most 1000 px, for the repair's page. Lists never download an original; clicking a photo opens it. Files are served through Active Storage's proxy routes (`config/application.rb`), so a variant's URL never expires and the browser caches it.
- **Diagnosis** (`has_rich_text :diagnosis`): written in the Trix editor, printed on the repair's page with its formatting through Action Text, and shown in each row as the first 60 characters of its plain text. It is optional. Nothing written by a person is printed with `raw` or `html_safe`; Action Text strips scripts and event handlers.
- **Queries**: every list of repairs and the repair's page preload the photos, their variants and the diagnosis in the controller (`with_attached_photos`, `with_rich_text_diagnosis_and_embeds`), so the number of queries doesn't depend on the number of repairs or photos.

## Seed photos

The bicycle photos in `db/seeds/` (`bike-01.jpg` … `bike-07.jpg`) are from [Unsplash](https://unsplash.com), used under the [Unsplash License](https://unsplash.com/license), which allows free use without attribution. They were converted from AVIF to JPEG.

## Documents

- [`docs/user-stories.md`](docs/user-stories.md) — the roles, the user stories, and their acceptance criteria.
- [`docs/domain-model.md`](docs/domain-model.md) — the relational diagram (DBML, built in dbdiagram.io) matching the current schema, the repair lifecycle, the entity-to-story traceability table, the two modelling decisions defended, and the changes made since Lab 3.
- [`docs/decisions.md`](docs/decisions.md) — three questions for the shop owner that the original description doesn't answer, and what changes in the model depending on the answer.
- [`docs/wireframes.md`](docs/wireframes.md) — the low-fidelity screens and the navigation graph between them.

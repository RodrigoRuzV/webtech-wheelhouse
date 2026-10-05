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

## Seed photos

The bicycle photos in `db/seeds/` (`bike-01.jpg` … `bike-07.jpg`) are from [Unsplash](https://unsplash.com), used under the [Unsplash License](https://unsplash.com/license), which allows free use without attribution. They were converted from AVIF to JPEG.

## Documents

- [`docs/user-stories.md`](docs/user-stories.md) — the roles, the user stories, and their acceptance criteria.
- [`docs/domain-model.md`](docs/domain-model.md) — the relational diagram (DBML, built in dbdiagram.io) matching the current schema, the repair lifecycle, the entity-to-story traceability table, the two modelling decisions defended, and the changes made since Lab 3 — lab by lab, up to the intake photos and the diagnosis of Lab 9.
- [`docs/decisions.md`](docs/decisions.md) — three questions for the shop owner that the original description doesn't answer, and what changes in the model depending on the answer.
- [`docs/wireframes.md`](docs/wireframes.md) — the low-fidelity screens and the navigation graph between them.

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
- PostgreSQL 16 (running locally)
- Node.js and Yarn (used to compile Bootstrap's CSS)

### Setup

    bundle install
    bin/rails db:prepare
    yarn install

### Start the server

    bin/dev

This starts Puma and the CSS watcher together. Visit http://localhost:3000.

As of Lab 4, the app has four public pages — Home, Services, Visiting the workshop, and About — built with Rails, PostgreSQL, and Bootstrap. There are no models, migrations, or database tables yet; that starts in Lab 5.

## Documents

- [`docs/user-stories.md`](docs/user-stories.md) — the roles, the user stories, and their acceptance criteria.
- [`docs/domain-model.md`](docs/domain-model.md) — the relational diagram (DBML, built in dbdiagram.io), the repair lifecycle, the entity-to-story traceability table, and the two modelling decisions defended.
- [`docs/decisions.md`](docs/decisions.md) — three questions for the shop owner that the original description doesn't answer, and what changes in the model depending on the answer.
- [`docs/wireframes.md`](docs/wireframes.md) — the low-fidelity screens and the navigation graph between them.

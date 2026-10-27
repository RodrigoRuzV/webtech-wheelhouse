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

`db:prepare` creates the development and test databases if they don't exist, runs every migration in `db/migrate/` (including the tables of Active Storage and Action Text), and — the first time, on a fresh clone — loads `db/seeds.rb` automatically. A fresh clone ends up with a full workshop's worth of data (services, staff and their accounts, customers, bikes, and repairs across every stage of the repair lifecycle, with their intake photos and diagnoses) with no separate seeding step. The seed's photos are copied into `storage/`, which git ignores: no uploaded file is ever committed. To reseed later without a fresh database, run `bin/rails db:seed` directly — it's safe to run more than once.

### Start the server

    bin/dev

This starts Puma and the CSS watcher together (the watcher compiles the CSS once when it starts). Visit http://localhost:3000/repairs: you are sent to sign in first (see the accounts below), and land back on the repairs after signing in. Every row shows the thumbnail of an intake photo and the beginning of the diagnosis. The first visit takes a moment while the thumbnails are generated; after that they are served from `storage/`. Use the navbar — Customers, Bikes, Repairs, Services and Staff each have a list page and a page per record, all read live from the database, so editing `db/seeds.rb` and reseeding changes what every page shows.

## Accounts (Lab 11)

Only the price list is public: http://localhost:3000/services and the page of each service. Every other page asks you to sign in with an email address and a password. Sign out with the button in the navigation bar.

The seed creates these accounts. **They exist only in development**: they are made by `db/seeds.rb` in your local database, and none of these passwords is used anywhere else.

| Email address | Password | Role | Member of the staff |
|---|---|---|---|
| `roberto@wheelhouse.test` | `owner-roberto-2026` | owner | Roberto Ibáñez |
| `valentina@wheelhouse.test` | `counter-valentina-26` | counter | Valentina Muñoz |
| `diego@wheelhouse.test` | `mechanic-diego-26` | mechanic | Diego Fuentes |
| `camila@wheelhouse.test` | `mechanic-camila-26` | mechanic | Camila Rojas |
| `martin@wheelhouse.test` | `mechanic-martin-26` | mechanic | Martín Soto |
| `trainee@wheelhouse.test` | `trainee-no-staff-26` | mechanic (the default) | — none |

- **Sign up** at http://localhost:3000/registration/new (linked from the sign-in page). A new account always gets the default role, `mechanic` (why: [`docs/decisions.md`](docs/decisions.md), decision 4), and belongs to no member of the staff. Passwords need at least 10 characters.
- **Changing a role, or joining an account to a member of the staff**, is done from the console; no page lists, edits or deletes accounts:

      bin/rails console
      user = User.find_by(email_address: "trainee@wheelhouse.test")
      user.update!(role: :counter, staff_member: StaffMember.find_by(name: "Valentina Muñoz"))

  (That example fails on the seed's data, on purpose: Valentina already has an account, and a member of the staff has at most one.)
- **Forgot your password?** Follow the link on the sign-in page. The email (below) brings a link that works once and expires in 15 minutes.

### Where the emails go in development

The application never sends a real email: there is no mail provider, no SMTP server and no credential, and nothing about email to configure. In development every email — the welcome email of a new account and the password-reset email — is delivered by the [`letter_opener`](https://github.com/ryanb/letter_opener) gem (installed by `bundle install`):

- it **opens in a new tab of your browser** the moment it is sent (a few seconds after the response, since emails leave from a background job);
- and it is **kept as a file in `tmp/letter_opener/`**, one folder per email, with its HTML part (`rich.html`) and its text part (`plain.html`). Open `rich.html` in a browser if the tab didn't open.

The link of the password email is a full URL to http://localhost:3000, so clicking it opens the form for a new password in the app running locally.

To see how each email looks without sending it, open the previews at http://localhost:3000/rails/mailers.

## The JSON API (Lab 10)

Wheelhouse also answers programs that are not a browser, with a versioned JSON API under `/api/v1`. Lab 11's accounts don't touch it: it needs no session and is never redirected to sign in; the private routes still use the token. Every route, document, status and decision is written down in [`docs/api.md`](docs/api.md).

- `GET /api/v1/services` and `GET /api/v1/services/:id` — the price list. **Public.**
- `POST /api/v1/services` — registers a service. **Needs the token.**
- `GET /api/v1/repairs` (optionally `?state=picked_up`) and `GET /api/v1/repairs/:id` — the repairs, for the accounting program. **Need the token.**

### Setting the token

The routes that need a token compare it with `api_token` in the application's **encrypted credentials**. The token is never in the code or in a committed file, and neither is `config/master.key` (git ignores it). A fresh clone has no `master.key`, so it can't read the committed `config/credentials.yml.enc`: create your own credentials and your own token.

    rm config/credentials.yml.enc          # only on a fresh clone without master.key
    bin/rails secret                       # prints a long random string: that is your token
    EDITOR="code --wait" bin/rails credentials:edit

In the editor that opens, add one line with the string `bin/rails secret` printed, save and close the file:

    api_token: paste-the-string-here

`credentials:edit` creates `config/master.key` (keep it, don't commit it) and encrypts the file again. Check it with:

    bin/rails runner 'puts Rails.application.credentials.api_token.present?'   # => true

### Asking the API from the terminal

Start the server with `bin/dev` (port **3000**), then, in another terminal:

    # The price list — public, no token
    curl -i http://localhost:3000/api/v1/services

    # The repairs that were handed back — with the token
    export WHEELHOUSE_TOKEN="the-token-you-put-in-credentials"
    curl -i -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
      "http://localhost:3000/api/v1/repairs?state=picked_up"

    # Registering a service — with the token and a JSON body
    curl -i -X POST http://localhost:3000/api/v1/services \
      -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"service": {"name": "Tubeless setup", "price": "35.00"}}'

Without the `Authorization` header (or with another token) the last two answer `401`.

### The price list on the personal page

The price list is shown on my personal page, published on GitHub Pages: **[rodrigoruzv.github.io/webtech-lab-01](https://rodrigoruzv.github.io/webtech-lab-01/)**. The page reads `http://localhost:3000/api/v1/services` from the browser, so to see the list **the API has to be running locally on port 3000** (`bin/dev`). The API allows that page's origin (`https://rodrigoruzv.github.io`) and the local server used while developing it (`http://localhost:8000`), and no other — see `config/initializers/cors.rb`.

## Seed photos

The bicycle photos in `db/seeds/` (`bike-01.jpg` … `bike-07.jpg`) are from [Unsplash](https://unsplash.com), used under the [Unsplash License](https://unsplash.com/license), which allows free use without attribution. They were converted from AVIF to JPEG.

## Documents

- [`docs/user-stories.md`](docs/user-stories.md) — the roles, the user stories, and their acceptance criteria.
- [`docs/domain-model.md`](docs/domain-model.md) — the relational diagram (DBML, built in dbdiagram.io) matching the current schema, the repair lifecycle, the entity-to-story traceability table, the two modelling decisions defended, and the changes made since Lab 3 — lab by lab, up to the intake photos and the diagnosis of Lab 9, the JSON API of Lab 10 and the accounts of Lab 11.
- [`docs/api.md`](docs/api.md) — the JSON API of Lab 10: its routes, the shape of each document and of an error, and its decisions (how a price travels, what a repair leaves out).
- [`docs/decisions.md`](docs/decisions.md) — three questions for the shop owner that the original description doesn't answer, and what changes in the model depending on the answer; plus Lab 11's decisions (the default role of an account, and who took a repair in).
- [`docs/wireframes.md`](docs/wireframes.md) — the low-fidelity screens and the navigation graph between them.

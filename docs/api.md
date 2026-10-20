# Wheelhouse API — v1

Wheelhouse answers two programs that are not a browser:

- **The shop's website**, on another origin, reads the wall list of services so people stop phoning to ask what a tune-up costs.
- **The shop's accounting program** reads the repairs that were handed back, with what was charged on each one. The owner also registers new services from a script.

Both read **JSON documents** from a versioned API. Everything lives under **`/api/v1`**: the version is a segment of the path, and `v1` keeps answering the same keys as long as it exists. Every response under `/api/v1` is `Content-Type: application/json`, errors included, whatever the request sends in `Accept`. The API never redirects, never renders a page, asks for no CSRF token and uses no session or cookie.

The base URL while developing is `http://localhost:3000/api/v1`.

## Routes

| Verb | Path | Token | Answers |
|---|---|---|---|
| `GET` | `/api/v1/services` | No | `200` |
| `GET` | `/api/v1/services/:id` | No | `200`, `404` |
| `POST` | `/api/v1/services` | **Yes** | `201` (with `Location`), `400`, `401`, `422` |
| `GET` | `/api/v1/repairs` | **Yes** | `200`, `400` (unknown `state`), `401` |
| `GET` | `/api/v1/repairs?state=:state` | **Yes** | `200`, `400` (unknown `state`), `401` |
| `GET` | `/api/v1/repairs/:id` | **Yes** | `200`, `401`, `404` |

There is no `new` and no `edit` (a program does not need a form), and no `update` or `destroy`: nobody asked for them.

### The token

The routes marked **Yes** need a token in the `Authorization` header, with the `Bearer` scheme:

    Authorization: Bearer <token>

A token in the query string or in the body is ignored. Without the header, or with another token, the API answers `401` before doing anything else. The token is the `api_token` of the application's encrypted credentials (see the README for how to set it).

### Who may call it from a browser (CORS)

Only `GET /api/v1/services` and `GET /api/v1/services/:id` are open to a page on another origin, and only to two origins: the personal page on GitHub Pages (`https://rodrigoruzv.github.io`) and the local server used while developing it (`http://localhost:8000`). The routes that need the token are not open to any origin. Requests without an `Origin` header (`curl`, the accounting program, a script) are answered normally: CORS is a rule for browsers.

## Documents

### A service

`GET /api/v1/services/1`

```json
{
  "id": 1,
  "name": "Tune-up",
  "price": "45.00",
  "repairs_count": 3
}
```

| Key | |
|---|---|
| `id` | The service's id, to ask for it again. |
| `name` | As on the wall list. |
| `price` | The list price today, as a string with two decimals (see *How a price travels*). |
| `repairs_count` | **Not a column.** On how many repairs the service has been charged, so the client does not need a second request. |

The same shape is answered by `index` (one per element), `show` and `create`.

### A collection of services

`GET /api/v1/services` — ordered by name. The collection is the list: there are no pages.

```json
[
  { "id": 2, "name": "Bearing service", "price": "35.00", "repairs_count": 1 },
  { "id": 3, "name": "Brake adjustment", "price": "25.00", "repairs_count": 2 },
  { "id": 1, "name": "Tune-up", "price": "45.00", "repairs_count": 3 }
]
```

### Registering a service

`POST /api/v1/services`, with the token and `Content-Type: application/json`:

```json
{ "service": { "name": "Tubeless setup", "price": "35.00" } }
```

Only `name` and `price` are read; any other key is dropped. The answer is `201 Created`, the document of the new service in the body, and its URL in the `Location` header (`http://localhost:3000/api/v1/services/27`). A refused service answers `422` with the same sentences the form shows; a body with no attributes of a service (an empty body, `{}`, or a `service` with no known key) or a body that isn't valid JSON answers `400`.

### A repair

`GET /api/v1/repairs/7`

```json
{
  "id": 7,
  "state": "picked_up",
  "dropped_off_on": "2026-10-10",
  "promised_on": "2026-10-15",
  "returned_on": "2026-10-17",
  "customer_answer": "approved",
  "overdue": false,
  "total": "80.00",
  "customer": { "name": "Ana Pérez" },
  "bike": { "make": "Trek", "model": "Marlin 5", "serial_number": "WH-10234" },
  "lines": [
    { "service": "Tune-up", "price_charged": "45.00" },
    { "service": "Brake pad replacement", "price_charged": "35.00" }
  ]
}
```

| Key | |
|---|---|
| `id` | The repair's id. |
| `state` | One of the states of the lifecycle: `dropped_off`, `diagnosing`, `awaiting_approval`, `in_progress`, `declined_pickup_pending`, `ready_for_pickup`, `picked_up`. |
| `dropped_off_on` | The day the bike came in (`YYYY-MM-DD`). |
| `promised_on` | The day promised to the customer, or `null` if none was given yet. |
| `returned_on` | The day the bike was handed back, or `null` if it is still in the shop. |
| `customer_answer` | **Not a column.** The customer's answer to the quote, as the lifecycle names it: `"approved"`, `"declined"`, `"pending"` (quoted, no answer yet) or `null` (no quote was needed or given yet — a simple same-day job, or a bike not diagnosed yet). |
| `overdue` | **Not a column.** `true` when the promised day has passed and the bike hasn't been handed back. |
| `total` | **Not a column.** The sum of the prices charged on the lines, as a string with two decimals. |
| `customer` | The customer who brought the bike in, with their name. |
| `bike` | The bike, with its make, model and serial number. |
| `lines` | The jobs of the repair: the name of the service and the price charged on this repair (which may differ from today's list price). |

No key is a foreign key: the bike, the customer and the lines travel inside.

### A collection of repairs

`GET /api/v1/repairs?state=picked_up` — newest first. Without `state`, every repair. The collection is the list: there are no pages.

```json
[
  {
    "id": 9,
    "state": "picked_up",
    "dropped_off_on": "2026-10-20",
    "promised_on": null,
    "returned_on": "2026-10-20",
    "customer_answer": null,
    "overdue": false,
    "total": "15.00",
    "customer": { "name": "Javier Torres" },
    "bike": { "make": "Trek", "model": "Marlin 5", "serial_number": "WH-10567" },
    "lines": [ { "service": "Flat tire repair", "price_charged": "15.00" } ]
  },
  {
    "id": 7,
    "state": "picked_up",
    "…": "the rest of the repair, as above"
  }
]
```

### An error

Every error, whatever its status, is an object with one key, `errors`, whose value is a list of strings. A client handles every error in one place.

`GET /api/v1/repairs?state=lost` → `400`

```json
{
  "errors": [
    "state must be one of: dropped_off, diagnosing, awaiting_approval, in_progress, declined_pickup_pending, ready_for_pickup, picked_up"
  ]
}
```

| Status | When | Example message |
|---|---|---|
| `400` | The body carries no attributes of a service, the body isn't valid JSON, or `state` has a value that isn't a state | `param is missing or the value is empty or invalid: service` |
| `401` | The token is missing or wrong, on a route that needs it | `Unauthorized: send a valid token in the Authorization header (Bearer)` |
| `404` | There is no record with that id | `Service 999 not found` |
| `422` | A validation failed | `Name has already been taken`, `Price must be greater than 0` |

## Decisions

### How a price travels

**As a string with exactly two decimals: `"45.00"`.** It applies to every price in the API: `price` of a service, `price_charged` of a line and `total` of a repair.

- Prices are `decimal(8, 2)` columns: exact amounts of money. A JSON number is read by JavaScript (and by most clients) as a binary floating-point number, where `0.1 + 0.2` is not `0.3`. An accounting program adding the lines of many repairs must not lose cents to that.
- A string keeps the amount exactly as the database holds it; the client converts it to its own decimal type, or, to show it, to a `Number` passed to `Intl.NumberFormat` (that is what the personal page does).
- Always two decimals, so `"45.00"` and never `"45.0"` or `"45"`: one format to parse.

### What the document of a repair leaves out, and why

The accounting program needs what was charged, to whom, on which bike and when. It does not need:

- **The customer's phone** — personal data the shop collects to call the customer, not to bill. A document that travels to another program carries no more personal data than it needs. Only the customer's name goes.
- **The staff** — who took the bike in, which mechanic worked on it, who handed it back. Internal to the workshop; accounting bills the repair, not the person.
- **The diagnosis and the intake photos** — the mechanic's notes and pictures of the bike. Large, internal, and of no use to an invoice.
- **The internal timestamps** (`quoted_at`, `finished_at`, `created_at`, `updated_at`) — the document carries the three days accounting reads (`dropped_off_on`, `promised_on`, `returned_on`) and the customer's answer that the quote time stood for.
- **Every foreign key** (`bike_id`, `customer_id`, `mechanic_id`, …) — an id is a way to ask a second time; the bike and the customer travel inside instead.
- **The service's list price on each line** — the line carries the price charged on this repair, which is what was billed; today's list price is in the services API.

### Queries

`GET /api/v1/services` runs 2 queries (the services, and the lines that charged them) and `GET /api/v1/repairs` runs 5 (repairs, customers, bikes, lines and services), whatever the number of rows. The preloading is in the API's controllers; the models did not change for it.

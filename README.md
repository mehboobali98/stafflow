# Stafflow

A multi-tenant HR management system built with Ruby on Rails. One deployment
serves many companies, each isolated on its own subdomain with its own
employees, org structure, leave policy, benefits and payroll history.

> Originally built as a team project in 2021 under the name PMS. Renamed and
> modernised since. See [ROADMAP.md](ROADMAP.md) for what is planned next and
> [CONTRIBUTING.md](CONTRIBUTING.md) for the branching model.

## Running it

You need Docker. Nothing else — Ruby, MySQL, Node and Elasticsearch all run in
containers.

```sh
git clone git@github.com:mehboobali98/stafflow.git
cd stafflow
cp .env.example .env

docker compose up -d db elasticsearch mail
docker compose run --rm web bundle exec rails db:create db:migrate db:seed
docker compose up -d web worker
```

The first request compiles the webpack bundle and takes a minute or two.

Then open **<http://acme.localhost:3000>** and sign in:

| Role | Email | Password |
| --- | --- | --- |
| Account owner | `owner@example.com` | `password123` |
| HR | `hr@example.com` | `password123` |
| Department head | `head@example.com` | `password123` |
| Employee | `employee@example.com` | `password123` |

Each role sees a different application — that is the point of the permission
model, so it is worth signing in as more than one.

Outbound mail is captured by MailHog at <http://localhost:8025> rather than
being delivered.

If port 3000 is already in use, set `WEB_PORT` in `.env`.

### The subdomain matters

Tenants are resolved from the subdomain, so `localhost:3000` is the public
marketing page and `acme.localhost:3000` is the Acme tenant. Browsers resolve
`*.localhost` to `127.0.0.1` automatically; no hosts-file entry is needed.

## How it works

### Multi-tenancy

Every tenant-owned table carries a `company_id`, and the scoping is applied
automatically rather than being left to individual queries.

`ApplicationRecord.inherited` installs a `TracePoint` that fires when a model
class finishes being defined, and gives it a default scope:

```ruby
default_scope { where(company_id: Company.current_company_id) }
```

A model opts out by calling `set_not_multitenant` in its body — `Company`
itself is the only one that does.

The current tenant lives in `Thread.current`, set by an `around_action` in
`ApplicationController` that resolves the subdomain and clears the value in an
`ensure` block, so a thread cannot leak tenant context into the next request it
serves.

```
request to acme.localhost
        │
        ▼
ApplicationController#set_current_company
  Company.find_company_by_subdomain!("acme")
  Thread.current[:current_company_id] = company.id
        │
        ▼
any query on any model
  ... WHERE company_id = 5      ← injected by the default scope
        │
        ▼
ensure: Thread.current[:current_company_id] = nil
```

### Authorization

Four roles — account owner, HR, department head, employee — implemented with
CanCanCan. Rather than one large `Ability` class, permissions are split by
resource into `app/models/concerns/*_abilities.rb`, each contributing rules for
one part of the domain.

### Leave workflow

Leave types carry a default allowance. Each employee gets a `UserLeave` balance
per type. Applying draws against the remaining balance; HR and department heads
approve or reject, individually or in bulk. Balances reset on a schedule driven
by `whenever` (`lib/tasks/leave.rake`).

### Payroll

`Payroll.generate_payroll` runs in a transaction: it applies the company tax
rate to the base salary, sums the employee's assigned benefits into itemised
`AppliedBenefit` rows, and stores the gross. The department head is notified by
a background email.

## Stack

| | |
| --- | --- |
| Ruby / Rails | 2.7.1 / 6.0.4 |
| Database | MySQL 8 |
| Search | Elasticsearch 7 via Searchkick |
| Background jobs | delayed_job |
| Auth | Devise |
| Authorization | CanCanCan |
| Assets | Webpacker 5, Bootstrap 5 |
| Charts | Chartkick |
| Scheduling | whenever |

## Layout

```
app/
  controllers/        thin; filtering via has_scope, pagination via will_paginate
  models/
    concerns/         one *_abilities.rb per resource (CanCanCan rules)
    application_record.rb   multi-tenant default scope installation
  views/
config/
  locales/en.yml      every user-facing string; no hardcoded copy in views
db/
  migrate/            41 migrations
  seeds.rb            builds one complete demo tenant
```

## Known gaps

Honest list of what this project does not have yet. [ROADMAP.md](ROADMAP.md)
sequences the work to close these, and carries the full defect backlog with
line numbers.

- **No test suite.** `capybara` and `selenium-webdriver` are in the Gemfile but
  no specs were ever written. This is the biggest gap.
- **No CI.**
- **Ruby 2.7 and Rails 6.0 are both end-of-life.** The Docker setup pins the
  contemporary toolchain so the app runs today, but upgrading is outstanding
  work.
- **Paperclip** was retired upstream in 2018; migrating to ActiveStorage is
  outstanding.
- `EMAIL_REGEX` in `config/initializers/constants.rb` only accepts `.com`
  addresses, which is why the seed data uses `example.com`.
- Seven known defects, two of which crash on ordinary input. Listed with
  locations in [ROADMAP.md](ROADMAP.md#defect-backlog).

## Contributors

Built by four engineers. Areas reflect what each person primarily worked on,
derived from the commit history.

| | |
| --- | --- |
| Nadia Ahsan | Departments, designations |
| Abdul Basit | Devise authentication, employee records |
| Shehryar Khan | Benefits, payroll |
| Mehboob Ali | Leave workflows, events calendar |

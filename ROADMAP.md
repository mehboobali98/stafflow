# Roadmap

A multi-tenant HR system in Rails, built by four engineers in 2021 and now
being brought back to a state worth showing. The architecture was always the
strong part. This is the sequence for making the rest match it.

Phases are ordered by what a reviewer notices first, not by what is most
interesting to build. Phases 1 and 2 are the ones that change how the repo
reads; everything after is depth.

## Where it stands

The app runs from a clean clone in three commands, with a suite in front of it
and the known defects cleared. What it still lacks is a modern stack and
somewhere to run.

| | |
| --- | --- |
| Commands to run from a clean clone | 3 |
| Tests | 191 examples, 0 pending |
| CI workflows | RSpec, RuboCop and Brakeman on push and PR |
| Lines in `app/` | 5,224 across 23 controllers, 29 models, 121 views |
| Known defects | 15 found, 14 fixed, 1 open |

---

## Phase 0 — Make it presentable ✅

*Shipped.*

The repo could not be cloned and run, and the landing page carried another
company's marketing copy. Both are now fixed.

- [x] Renamed `PMS` to Stafflow across module, title, database and CSS
- [x] Fixed four duplicate top-level i18n keys silently dropping translations,
      and 12 broken `t()` lookups
- [x] Replaced landing copy that was branded as a real competitor product, with
      fabricated testimonials and machine-translated Cicero
- [x] Purged contributor photos and live Paperclip uploads from git history
- [x] Established git-flow: `main` and `develop`, both protected, feature and
      hotfix branches documented in [CONTRIBUTING.md](CONTRIBUTING.md)
- [x] Docker Compose stack, committed `db/schema.rb`, real seed data, rewritten
      README

---

## Phase 1 — Tests and CI ✅

*Shipped.*

This is the single loudest gap. An engineer reading this repo sees non-trivial
architecture with nothing verifying it, and has to take the whole thing on
faith. Tests are also the only credible way to demonstrate that tenant
isolation actually holds.

- [x] RSpec, factory_bot, shoulda-matchers
- [x] **Tenant isolation specs.** Create two companies, assert that queries
      under one never return the other's rows, and that clearing the
      thread-local scopes correctly. *The highest-value tests in the suite —
      this is the architecture you will be asked about.*
- [x] **Ability matrix specs.** Four roles across every resource, driven from a
      table rather than written out longhand
- [x] **Payroll calculation specs.** Tax applied to base salary, benefits
      itemised, gross correct, transaction rolls back on invalid
- [x] Leave workflow specs: apply against balance, approve, reject, bulk
      approve, balance decrements exactly once
- [x] Request specs for sign-in, subdomain resolution, and the 403 / 404 paths
- [x] GitHub Actions running RSpec, RuboCop and Brakeman with MySQL and
      Elasticsearch services
- [x] Add `.rubocop.yml` — the code is already written in RuboCop style, it
      just has no config

Writing the suite uncovered three defects that no amount of reading had found,
all fixed here because each one blocked the specs that found it:

- **Leave approval never worked.** `validate_leave_count` is used as a state
  machine guard but was written as `raise ArgumentError unless leave_available?`,
  which evaluates to `nil` when the leave *is* available. The transitions gem
  treats a nil guard as "not executable", so every approval silently did
  nothing and still reported success.
- **Full-day leaves deducted half a day.** `LEAVE_DURATION` is a
  `HashWithIndifferentAccess`, so `invert` yields String keys, and
  `leave_duration_name.eql?(:full_day)` compared a String to a Symbol — always
  false. Every full-day leave took the half-day branch.
- **Payroll generation crashed** on the `.nil` typo described in the backlog.

Three more were found and left recorded as pending specs rather than fixed
here: see the backlog below.

---

## Phase 2 — Clear the known defects ✅

*Shipped.*

- [x] Fix the remaining crasher — leave-update validation raises on ordinary
      input (`applied_leaves_controller.rb:66`)
- [x] Stop `before_save :build_company_setting` resetting configured settings
      on every company save
- [x] Give the error handlers real status codes, where a 403 returned `200 OK`
      and the page went out as raw ERB
- [x] Stop `leave_reset_date_valid?` raising `Date::Error` on the nil the
      column starts at
- [x] Let a leave balance reach zero, so an employee can spend their last day
- [x] Widen `EMAIL_REGEX` beyond `.com` and anchor it at both ends
- [x] Resolve the two remaining nested i18n duplicates — settled on the
      singular "Leave type", which is what both call sites are: column headers
      over a column holding one leave type per row
- [x] Replace `html_safe` string interpolation in `users_helper` with a tag
      builder

Every spec that was pending is now green: 160 examples, none pending.

Fixing the leave-update crasher turned up two further defects stacked in front
of it, both of the same kind the suite found in phase 1 — a comparison between
values that were never the same type:

- **No leave application could be edited or withdrawn, by anyone.** The CanCan
  rules conditioned `update` and `destroy` on `state: :pending`, but `state` is
  a string column. CanCan compares the condition to the attribute with `==`,
  and `'pending' == :pending` is false, so the rule matched for no role at all
  and every attempt answered with the unauthorized page. `AppliedLeave` had no
  section in the ability matrix, which is how a rule that denied everyone went
  unnoticed; it has one now.
- **Clearing a date on the leave form returned a 500.** `validate_leave_dates`
  and `validate_past_leave_date` compare the two dates, and Rails runs custom
  validators alongside the presence validator rather than after it, so a blank
  field arrives as `nil` and the comparison raises. The presence error the user
  should have seen was never reached.

Fixing the zero-balance defect turned up a second half to it: `count_available?`
treated a request as available only when it was *strictly* less than the
remaining balance, so asking for exactly the days left was refused before the
validation was ever reached. Both halves were needed for an employee to spend
their last day.

One further finding, recorded rather than fixed: `public/404.html` and
`public/500.html` are served by `ActionDispatch::Static` ahead of the router,
so the styled pages behind the `/404` and `/500` routes never render while the
static file server is on. It always is in test, and in production whenever
`RAILS_SERVE_STATIC_FILES` is set — which matters for phase 4. `/401` and
`/403` have no static counterpart and render normally. Deleting the static
files would fix it but costs the fallback that works when the app cannot boot,
so it is a deployment decision rather than a defect.

Two rows are left in the backlog below. Neither was in this phase's checklist
and neither is reachable from ordinary use, so the phase closes here rather
than absorbing them; they are described where they sit.

---

## Phase 3 — Modernise the stack

**In progress.** Estimated 3–5 weeks.

Ruby 2.7 and Rails 6.0 are both past end of life, and the original repo reports
132 dependency vulnerabilities. This is the largest phase, and it is also the
best interview story in the project — a real legacy upgrade with a test suite
underneath it, which is why it comes after Phase 1 rather than before.

- [x] Replace the `sequenceid` dependency, which was pinned to a branch on a
      third-party fork — if that branch disappeared the app stopped building.
      Done first, since it patched ActiveRecord STI internals and would have
      been an unknown in every step below
- [ ] Ruby and Rails, interleaved. **The two cannot be done in sequence:**
      Rails 6.0 does not support Ruby 3.x, and 6.1 was the first release that
      did, so raising Ruby first leaves the app unable to boot. The suite runs
      at every stop:

      | | |
      | --- | --- |
      | Rails 6.0 → 6.1 | still on Ruby 2.7 |
      | Ruby 2.7 → 3.0 | 6.1 is the first Rails that supports 3.x |
      | Rails 6.1 → 7.0 | |
      | Ruby 3.0 → 3.2 | |
      | Rails 7.0 → 7.1 | |
      | Ruby 3.2 → 3.3 | |

- [ ] Paperclip → ActiveStorage. Paperclip was retired upstream in 2018; needs
      a data migration for existing attachments
- [ ] Webpacker 5 → `jsbundling-rails` with esbuild, or Propshaft plus
      importmaps
- [ ] Clear the Dependabot backlog once the framework bumps land
- [ ] Revisit the `TracePoint` multi-tenancy hook against modern Rails
      autoloading. `event.rb` in the defect backlog belongs with this, since
      both turn on how the hook injects `company_id`

**Done when:** the suite passes on Rails 7.1 and Ruby 3.3, and no dependency is
pinned to a git branch.

---

## Phase 4 — Live demo

Estimated 3–5 days.

Most people who open the repo will never run it. A URL they can click, sign
into as four different roles, and poke at is worth more than any amount of
README prose.

- [ ] Deploy to Fly.io or Render with managed MySQL
- [ ] **Wildcard subdomain routing and a wildcard TLS certificate.**
      Non-negotiable — without `*.domain` the multi-tenancy cannot be
      demonstrated at all
- [ ] Managed Elasticsearch, or make Searchkick optional so search degrades
      rather than breaks
- [ ] Nightly job that resets the demo tenant to seed state
- [ ] Sign-in credentials for all four roles printed on the demo landing page

**Done when:** a stranger can reach a working dashboard in two clicks from the
README.

---

## Phase 5 — Depth in the domain

Optional, ongoing.

Everything above restores the project. This is where you extend it, and where
the work stops being someone else's and starts being yours. Pick one or two,
not all five — depth in one area reads better than breadth across all of them.

- [ ] Leave accrual and carryover policies. The current model is a flat annual
      reset; real HR systems accrue monthly and cap carryover
- [ ] Payslip PDF generation and payroll history per employee
- [ ] Audit log for changes to salary, role and leave balance — the obvious
      next thing any HR system needs
- [ ] A JSON API with token auth and documented endpoints
- [ ] Richer analytics: headcount over time, leave utilisation by department,
      payroll cost trend

---

## Phase 6 — Present the work

Optional. Estimated 2–3 days.

The engineering is only half of it. Someone deciding whether to interview you
spends about ninety seconds here.

- [ ] Architecture diagram in the README showing subdomain → tenant scope →
      query
- [ ] Screenshots or a short capture of the leave approval flow
- [ ] A short write-up of one hard problem and how it was solved — the
      `TracePoint` tenancy hook is the obvious candidate
- [ ] Keep the README's "Known gaps" section honest as items get closed

---

## Defect backlog

Line numbers current as of 28 Aug 2026.

### Open

| Location | Problem | Effect | Severity |
| --- | --- | --- | --- |
| `app/models/payroll.rb:30` | `payroll` is referenced in the `rescue` but only assigned inside the transaction block, where it is block-local | The rescue raises `NameError` over the `RecordInvalid` it meant to handle. No spec reaches this path | Wrong |
| `app/models/event.rb` | Tenant-scoped by the default scope but declares no `belongs_to :company`, unlike every other tenant model | Works only because the default scope injects the id; `Event.new(company:)` fails. `event.rb:17` also rescues `Type::Error`, which is not a class that exists | Tidy |

Neither was in the phase 2 checklist, and neither is reachable from ordinary
use. `event.rb` is worth doing alongside the `TracePoint` review in phase 3,
since both turn on how the tenancy hook injects the company id.

### Fixed

Phase 1, each with a regression spec: `payroll.rb:46` (`.nil` typo),
`applied_leave.rb` state machine guard returning nil, and `applied_leave.rb`
full-day duration comparison.

Phase 2, each with a regression spec:

| Location | Problem |
| --- | --- |
| `app/models/concerns/applied_leave_abilities.rb` | `state: :pending` compared a symbol to a string column, denying `update` and `destroy` to every role |
| `app/models/applied_leave.rb` | Date validators compared `nil` when a date field was cleared, returning a 500 instead of the presence error |
| `app/controllers/applied_leaves_controller.rb:66` | `@leave` never assigned in `update`; should be `@applied_leave` |
| `app/models/company.rb:20` | `before_save :build_company_setting` ran on every save, resetting the configured tax rate |
| `app/models/setting.rb:10` | `DateTime.parse(leave_resets_at.to_s)` raised `Date::Error` on the nil the column starts at |
| `app/models/user_leave.rb:8` | `remaining_count` validated `greater_than: 0`, and `count_available?` compared with `<`, so the last day of an allowance could be neither requested nor saved |
| `app/controllers/application_controller.rb:8,12` | `render file:` served raw ERB under `200 OK` for denied and missing resources |
| `config/initializers/constants.rb:3` | `EMAIL_REGEX` accepted only `.com` and was unanchored at the end |
| `config/locales/en.yml:217,233` | `applied_leave.headings.leave_type` defined twice; the plural silently won |
| `app/helpers/users_helper.rb:19` | Model error text interpolated into an `html_safe` string |

---

## Why this order

**Tests come before the upgrade, not after.** Upgrading Rails without a suite
means changing a framework by hand and hoping. With the suite in place, the
upgrade becomes a series of red-to-green steps you can describe in an
interview — which is the entire reason the upgrade is worth doing at all.

**Bug fixes come after tests for the same reason.** A fix with a failing test
in front of it is evidence. A fix on its own is a diff.

**The demo comes before new features.** A deployed app with four roles to
explore does more for the project than a fifth module nobody can reach.

**Phase 5 is genuinely optional.** Stopping after Phase 4 leaves a tested,
modern, deployed, honestly-documented multi-tenant Rails application. That is
already a strong piece of work. Only continue into Phase 5 if you want the
project to be yours rather than the team's.

# Roadmap

A multi-tenant HR system in Rails, built by four engineers in 2021 and now
being brought back to a state worth showing. The architecture was always the
strong part. This is the sequence for making the rest match it.

Phases are ordered by what a reviewer notices first, not by what is most
interesting to build. Phases 1 and 2 are the ones that change how the repo
reads; everything after is depth.

## Where it stands

The app runs from a clean clone in three commands. What it still lacks is
everything that proves the code works.

| | |
| --- | --- |
| Commands to run from a clean clone | 3 |
| Tests | 0 — `capybara` sits in the Gemfile unused |
| CI workflows | 0 — nothing runs on push |
| Lines in `app/` | 5,224 across 23 controllers, 29 models, 121 views |
| Known defects | 7, two of which crash on ordinary input |

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

## Phase 1 — Tests and CI

**Do this next.** Estimated 1–2 weeks.

This is the single loudest gap. An engineer reading this repo sees non-trivial
architecture with nothing verifying it, and has to take the whole thing on
faith. Tests are also the only credible way to demonstrate that tenant
isolation actually holds.

- [ ] RSpec, factory_bot, shoulda-matchers, database_cleaner
- [ ] **Tenant isolation specs.** Create two companies, assert that queries
      under one never return the other's rows, and that clearing the
      thread-local scopes correctly. *The highest-value tests in the suite —
      this is the architecture you will be asked about.*
- [ ] **Ability matrix specs.** Four roles across every resource, driven from a
      table rather than written out longhand
- [ ] **Payroll calculation specs.** Tax applied to base salary, benefits
      itemised, gross correct, transaction rolls back on invalid
- [ ] Leave workflow specs: apply against balance, approve, reject, bulk
      approve, balance decrements exactly once
- [ ] Request specs for sign-in, subdomain resolution, and the 403 / 404 paths
- [ ] GitHub Actions running RSpec, RuboCop and Brakeman with MySQL and
      Elasticsearch services
- [ ] Add `.rubocop.yml` — the code is already written in RuboCop style, it
      just has no config

**Done when:** a green CI badge sits at the top of the README, and the tenant
isolation spec fails if someone removes the default scope.

---

## Phase 2 — Clear the known defects

Estimated 2–3 days.

Seven defects found by reading the code, listed in full below. Doing this after
Phase 1 means each fix lands with a test that proves it, which is worth more
than the fix alone.

- [ ] Fix the two crashers first — payroll email delivery and leave-update
      validation both raise on ordinary input
- [ ] Give the error handlers real status codes; a 403 currently returns
      `200 OK`
- [ ] Widen `EMAIL_REGEX` beyond `.com` and anchor it at both ends
- [ ] Resolve the two remaining nested i18n duplicates — needs a copy decision:
      "Leave type" or "Leave types"
- [ ] Replace `html_safe` string interpolation in `users_helper` with a tag
      builder

**Done when:** the defect table below is empty, and each row has a regression
test behind it.

---

## Phase 3 — Modernise the stack

Estimated 3–5 weeks.

Ruby 2.7 and Rails 6.0 are both past end of life, and the original repo reports
132 dependency vulnerabilities. This is the largest phase, and it is also the
best interview story in the project — a real legacy upgrade with a test suite
underneath it, which is why it comes after Phase 1 rather than before.

- [ ] Ruby 2.7.1 → 3.3 — mostly keyword-argument fallout
- [ ] Rails 6.0 → 6.1 → 7.0 → 7.1, one minor at a time, running the suite at
      each step
- [ ] Paperclip → ActiveStorage. Paperclip was retired upstream in 2018; needs
      a data migration for existing attachments
- [ ] Webpacker 5 → `jsbundling-rails` with esbuild, or Propshaft plus
      importmaps
- [ ] Replace the `sequenceid` dependency, currently pinned to a branch on a
      third-party fork — if that branch disappears the app stops building
- [ ] Clear the Dependabot backlog once the framework bumps land
- [ ] Revisit the `TracePoint` multi-tenancy hook against modern Rails
      autoloading

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

Found by reading the code, all still present on `develop`. Line numbers current
as of 28 Aug 2026.

| Location | Problem | Effect | Severity |
| --- | --- | --- | --- |
| `app/models/payroll.rb:46` | `.nil` is not a method, and an account owner has no department to call it on | Raises `NoMethodError` in an `after_create` hook whenever payroll is generated | **Crash** |
| `app/controllers/applied_leaves_controller.rb:66` | `@leave` is never assigned in `update`; should be `@applied_leave` | Every validation failure on a leave update raises instead of showing the error | **Crash** |
| `app/models/payroll.rb:29` | `payroll` is referenced in the `rescue` but only assigned inside the transaction block | The rescue path returns nothing useful | Wrong |
| `app/controllers/application_controller.rb:8,12` | `render file:` with a relative path, and no status code set | 403 and 404 responses return `200 OK`; the template renders raw, without ERB or layout | Wrong |
| `config/initializers/constants.rb:3` | `EMAIL_REGEX` accepts only `.com`, and is unanchored at the end | Rejects `.org`, `.io`, `.co.uk`; accepts `a@b.com.evil` | Wrong |
| `config/locales/en.yml:217,233` | `applied_leave.headings.leave_type` defined twice, as "Leave type" and "Leave types" | The later definition silently wins everywhere | Tidy |
| `app/helpers/users_helper.rb:19` | Model error text interpolated into an `html_safe` string | Low practical risk, but it is what a reviewer greps for | Tidy |

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

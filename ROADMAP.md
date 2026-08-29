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
| Tests | 196 examples, 0 pending |
| CI workflows | RSpec, RuboCop and Brakeman on push and PR |
| Lines in `app/` | 5,224 across 23 controllers, 29 models, 121 views |
| Known defects | 17 found, 16 fixed, 1 open |

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

      | | | |
      | --- | --- | --- |
      | ✅ | Rails 6.0 → 6.1 | still on Ruby 2.7 |
      | ✅ | Ruby 2.7 → 3.0 | 6.1 is the first Rails that supports 3.x |
      | ✅ | Rails 6.1 → 7.0 | |
      | ✅ | Ruby 3.0 → 3.2 | 3.1 skipped; nothing needs it as a stop |
      | ✅ | Rails 7.0 → 7.1 | |
      | ✅ | Ruby 3.2 → 3.3 | |

The Ruby 3.0 step needed one dependency moved and turned up two pieces of dead
code that only Ruby 3.0 can see:

- **Every Rails command crashed at boot** under bootsnap 1.9.1. Ruby
  [Bug #18250] makes `RubyVM::InstructionSequence#to_binary` raise on a method
  that takes an anonymous splat and forwards it through a bare `super` inside a
  block — `thor/base.rb` defines three. bootsnap caches compiled iseqs, so it
  hit the bug on the first `require`. bootsnap 1.9.2 detects the bug and skips
  the files it affects — the lockfile sat exactly one patch release behind the
  fix, on a gem the Gemfile never pinned.
- `.freeze` on the `EMAIL_REGEX` and `PASSWORD_LENGTH` literals, and `.sort` on
  the `Dir[]` glob in `rails_helper`, are all no-ops as of Ruby 3.0, which
  froze Regexp and Range literals and made glob results sorted by default.

Brakeman now reports zero warnings, which is worth reading carefully rather
than as a clean bill of health: Ruby 3.0 went out of support in March 2024, but
Brakeman 5.4.1's table writes that range as `['3.0.0', '2.8.99']`, which no
version satisfies, and its Rails table has no entry past 6.0. The stack is two
steps less current than the check can say.

- [x] Enable the Rails 6.1 framework defaults. Both flips that were flagged for
      hand-checking turned out to be safe, and the first one fixed a form that
      had never worked:

      `action_view.form_with_generates_remote_forms` was expected to affect two
      forms. Only one exists. `users_benefits/new.html.erb` is dead — routes
      declare `except: %i[create show new]`, the controller has no `new`, and
      the view calls `member_users_benefit_mass_create_path`, which is not a
      route helper this app generates; it has been deleted.
      `applied_leaves/new_applied_leave_by_hr` was the real one, and it rendered
      `data-remote="true"` against a controller that only answers `format.html`
      and redirects, so the XHR followed the redirect, got HTML back, and
      rails-ujs did nothing with it — the submit button appeared dead. The flip
      makes it an ordinary POST, and it now redirects and persists.

      `action_dispatch.cookies_same_site_protection` was a false alarm. The
      sign-in form posts to `/users/sign_in` on the same host it was served
      from, so nothing crosses an origin; the only apex-to-subdomain hop is the
      top-level GET link on `display_companies`, which `:lax` permits and which
      carries no session yet. Subdomains of one registrable domain are same-site
      regardless. The cookie previously carried no `SameSite` attribute at all,
      which browsers have themselves defaulted to `Lax` since 2020, so this
      writes down behaviour the app already had.

The Rails 7.0 step was a dependency problem rather than an application one.
Nothing in `app/` had to change, and the suite went from 193 green on 6.1 to
193 green on 7.0 untouched. Two gems moved, both because a declared bound was
wrong:

- **devise 4.8.0 killed the app on the first `require`.** It calls
  `ActiveSupport::Dependencies.reference`, which 7.0 removed, but its gemspec
  accepts `railties >= 4.1`, so the resolver had no way to know. 4.8.1 is the
  release that fixed it. Devise 5.0.4 also resolves cleanly and was
  deliberately not taken — replacing the authentication stack inside a
  framework bump would make the step unbisectable, and the dependency sweep
  below is where that belongs.
- **delayed_job needed a ceiling.** `delayed_job_active_record` was pinned at
  4.1.6, which caps `activerecord` below 6.2. Lifting that pin let the resolver
  take `delayed_job` 4.2.0 along with it, whose ActiveJob adapter subclasses
  `ActiveJob::QueueAdapters::AbstractAdapter` and which shadows the adapter of
  the same name that 7.0 itself ships. Its gemspec asks only for
  `activesupport >= 3.0`, so it is now pinned below 4.2 in the same way, and
  for the same reason, as `concurrent-ruby`. *(Recorded here at the time as a
  class Rails 7.1 introduced. That was wrong: 7.1 does not ship it either, as
  the 7.1 step found out by removing the pin. It arrives in 7.2, and the pin
  says so now.)*

`return` from inside a transaction rolls back as of 7.0 rather than only
warning; `payroll.rb` was the only place doing it and had already been
restructured during the 6.1 step.

Of the 7.0 defaults now staged, one is not cosmetic.
`action_controller.raise_on_open_redirects` rejects a `redirect_to` whose host
is not the request's, and sign-in reaches a tenant by exactly that route —
`home_controller.rb:14` redirects from the apex host to
`new_user_session_url` on the company's subdomain. Enabling it without
`allow_other_host: true` closes the front door of the application, and that
redirect has no spec covering it today.

- [x] Enable the Rails 7.0 framework defaults. Of the two flagged for
      hand-checking, one was real and one turned out to be unreachable:

      `action_controller.raise_on_open_redirects` was the real one.
      `home_controller.rb` hands a visitor from the apex host to
      `new_user_session_url` on their company's subdomain, which is the only
      cross-host redirect the app makes and the way every session starts. It
      now says `allow_other_host: true`, and the path has a request spec, which
      it did not before.

      `active_support.executor_around_test_case` was raised because a query
      cache spanning a test case could serve one tenant's rows to another
      through the thread-local default scope. It changes nothing here, for a
      reason worth recording rather than treating as reassurance: Rails
      installs the executor through an `active_support_test_case` load hook, so
      it reaches only classes descending from `ActiveSupport::TestCase`.
      rspec-rails 5.1.2 does not, and never reads the flag — the config is true
      and the query cache is still off inside an example. The interaction is
      untested rather than safe, and goes live if the suite moves to
      rspec-rails 6.

      The rest are inert: no `button_to`, no scoped associations, no Active
      Storage, and `wrap_parameters_by_default` matches what
      `config/initializers/wrap_parameters.rb` already sets by hand. The two
      digest defaults rotate the key generator to SHA256 and invalidate every
      signed and encrypted cookie, which costs nothing while there is no
      deployment to sign anyone out of.
The Ruby 3.2 step cost two gems and a base image, and both gem failures were
of the kind a build check waves through:

- **capybara 3.35.3 required `matrix`,** which Ruby 3.1 moved out of the
  default gems and which capybara did not declare until 3.36. Every spec file
  died at load with `cannot load such file -- matrix`, before a single example
  ran. Nothing in the suite uses capybara — there are no system specs — it is
  simply in the `:test` group, so `Bundler.require` loads it.
- **mysql2 0.5.3 compiled cleanly and then died on the first query** with
  `undefined symbol: rb_tainted_str_new2`. Ruby 3.2 removed taint, and the
  symbol only has to exist when the extension is actually called, so the gem
  installs, the image builds, and the failure waits for the first database
  round trip. 0.5.7 fixes it.

The base image moved from Debian bullseye to bookworm, because the `ruby:3.2`
images do not ship a bullseye variant. That is a happy forcing function:
bullseye's LTS ended two days after this commit, and the Dockerfile carried a
workaround repointing apt at the Debian archive to survive it. Bookworm is
supported to 2028, so the workaround is gone rather than extended.
`ruby:3.2-bookworm` was taken over the default `ruby:3.2`, which is now Debian
13 — one OS step at a time, and Node 14 still has to run on it.

Brakeman still reports zero, and the reason has changed shape: its Ruby table
ends at 3.0 outright, so the inverted `['3.0.0', '2.8.99']` range described
above is no longer even what is hiding the EOL. Ruby 3.2 and Rails 7.0 are both
out of support and Brakeman 5.4.1 cannot say so about either, however old they
get.

RuboCop's `TargetRubyVersion` went to 3.2 with it, which turns on Ruby 3.1's
hash value omission and asks for `company: company` to become `company:` in 225
places. That is a restyle of the codebase rather than part of running on a
newer Ruby, so `Style/HashSyntax` is configured to accept both forms and the
sweep is left as its own decision.

The Rails 7.1 step took two gem bumps, released one pin, kept another, and
turned up the wall that stops the next one.

- **`concurrent-ruby` is unpinned, and the claim it carried held.** 1.3.5
  dropped a `require 'logger'` that ActiveSupport before 7.1 relied on, and
  7.1 requires it itself. Proved on the path that used to fail rather than
  from the changelog: `bin/webpack` run directly, from wiped volumes, on
  concurrent-ruby 1.3.8.
- **`delayed_job` stays pinned below 4.2, and the pin's reason was wrong.**
  Recorded during the 7.0 step as waiting on a class Rails 7.1 introduces.
  Removing the pin here proved otherwise — `AbstractAdapter` is not in 7.1
  either, and the suite failed to load exactly as it had on 7.0. It arrives in
  7.2. Rails ships its own delayed_job adapter meanwhile, and that is the one
  7.1 resolves.
- **puma 4.3.8 could not start the server.** Rails 7.1 brings Rack 3, which
  moved `Rack::Handler` out to the `rackup` gem; puma 4 registers itself
  against the old constant, so `rails server` answered "Could not find a server
  gem" with puma right there in the Gemfile. puma 6.6.1 is what 7.1 expects.
  Nothing in the suite touches puma, so only booting the app finds this.
- **devise 4.8.1 → 4.9.4,** which is the release that stops it reaching for
  `ActiveSupport::Dependencies` through a deprecated constant accessor.

### What now blocks Rails 7.2

The suite is green and silent about none of it: three gems still call APIs that
7.1 deprecates and 7.2 removes, so each is a prerequisite rather than a
nice-to-have.

| Gem | Call | Fixed in |
| --- | --- | --- |
| searchkick 4.6.0 | `color(name, YELLOW, true)` — bolding a log tag with a positional boolean | searchkick 5, which is also an Elasticsearch client migration |
| devise 4.9.4 | `Rails.application.secrets` in `secret_key_finder.rb` | devise 5 |
| rspec-rails 5.1.2 | `TestFixtures.fixture_path=` | rspec-rails 6.1 |

searchkick is the loud one — it warns once per query, which is several hundred
lines a suite run. That noise is left in place deliberately: silencing it would
hide the only signal saying the gem has to be replaced before 7.2.

The rspec-rails bump carries a consequence recorded during the 7.0 defaults
step: rspec-rails 6 descends from `ActiveSupport::TestCase`, so
`executor_around_test_case` stops being inert and the Active Record query cache
starts spanning test cases. That is the tenancy interaction the isolation specs
were written to catch, and it goes live in the same commit.

Ruby 3.3 cost nothing. No gem moved, the lockfile changed by one line, and the
suite, the asset build, the server and the worker all came up unchanged. Worth
recording precisely because the two Ruby steps before it were not like that:
3.0 needed bootsnap moved, and 3.2 needed capybara and mysql2. Nothing in this
app reaches for a stdlib method 3.3 changed, and nothing warns about the
default gems 3.4 will move out.

That closes the interleaved sequence. What is left of this phase is the gem
work the framework bumps were blocking.

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

Line numbers current as of 29 Aug 2026.

### Open

| Location | Problem | Effect | Severity |
| --- | --- | --- | --- |
| `app/models/event.rb` | Tenant-scoped by the default scope but declares no `belongs_to :company`, unlike every other tenant model | Works only because the default scope injects the id; `Event.new(company:)` fails. `event.rb:17` also rescues `Type::Error`, which is not a class that exists | Tidy |

`event.rb` is worth doing alongside the `TracePoint` review in phase 3, since
both turn on how the tenancy hook injects the company id. `payroll.rb` closed
during the Rails 6.1 upgrade: the deprecation that forced the transaction
block to be restructured took the block-local `rescue` with it.

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
| `app/models/payroll.rb` | `return` inside the transaction block, deprecated in 6.1 and a rollback in 7.0, and a `rescue` referring to a name local to that block |
| `app/helpers/users_helper.rb:19` | Model error text interpolated into an `html_safe` string |

Phase 3, with a regression spec:

| Location | Problem |
| --- | --- |
| `app/controllers/applied_leaves_controller.rb:9` | The controller-wide breadcrumb points at `member_applied_leaves_path`, which needs a member id. `new_applied_leave_by_hr` is reached from the company-wide list and carries none, so the layout raised and the page 500d for HR, the only role that can reach it |

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

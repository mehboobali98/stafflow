# Roadmap

A multi-tenant HR system in Rails, built by four engineers in 2021 and now
being brought back to a state worth showing. The architecture was always the
strong part. This is the sequence for making the rest match it.

Phases are ordered by what a reviewer notices first, not by what is most
interesting to build. Phases 1 and 2 are the ones that change how the repo
reads; everything after is depth.

## Where it stands

The app runs from a clean clone in three commands, on a current stack, with a
suite in front of it and the known defects cleared. What it still lacks is an
interface worth showing, and somewhere to show it — in that order, which is a
reversal of the sequence this file was written with and is argued at the end.

| | |
| --- | --- |
| Commands to run from a clean clone | 3 |
| Tests | 411 examples, 0 pending |
| CI workflows | RSpec, RuboCop and Brakeman on push and PR |
| Lines in `app/` | 4,939 across 22 controllers, 30 models, 121 views |
| Known defects | 40 found, 39 fixed, 1 open |

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

### Added after the phase shipped — browser coverage

The phase shipped with nothing in front of the pages, and the README said so.
What changed the calculation was two defects in one day, both found by a human
opening a page and neither reachable by anything CI ran: `require.context`
surviving the esbuild migration, and an I18n subtree printed into a table cell.

- [x] **System specs driving a real browser.** Capybara 3.40 with Cuprite,
      which speaks CDP to Chrome directly. No chromedriver, so none of the
      version coupling that left `webdrivers` pinning `selenium-webdriver`
      below 4.0 until both were deleted in phase 3. `js_errors: true` is the
      part that earns its place: an uncaught exception in the page raises in
      the example rather than sitting in a console nothing reads
- [x] Eight examples over the three pages carrying the most JavaScript — the
      landing page, sign-in through a subdomain to the dashboard, and the HR
      leave queue. `chromium` is installed in the Dockerfile; CI installs no
      browser, because the runner image already carries `google-chrome`

Two things are worth recording about how this fits the rest of the suite.
`driven_by :cuprite` does not look a driver up — Rails registers it itself and
overwrites anything registered under that name first, so a
`Capybara.register_driver(:cuprite)` block would have looked like configuration
and silently done nothing. And a browser has no equivalent of `host!`: the
tenant is steered by moving `Capybara.app_host` between the apex and a
subdomain of it, which works because Chromium routes any `*.localhost` name to
loopback without consulting DNS.

The first run of the first browser spec found two defects. Both are fixed here,
on the same reasoning as the three above: each one blocked the spec that found
it. Both are in the backlog.

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

### Added after the phase shipped — the float columns

Eleven columns held money and leave balances as `t.float`, and the note against
them was always the same: flagged repeatedly, never filed, because nobody had
demonstrated a failing case. Measuring the column produced one immediately.

`t.float` on MySQL is `FLOAT(24)` — single precision, roughly seven significant
decimal digits — not the `double` the name suggests. A salary needs more than
seven. Read back from the column, `1234567.89` is `1234570.0` and `100000.10`
is `100000.0`, and a payroll generated from a base of `100000.10` at 10% came
out `$87.74` short on the gross. That is not a rounding artefact to argue
about; it is a wrong payslip, and it was wrong for every salary carrying cents.

All eleven moved to `decimal`. Money is `decimal(15, 2)`, the tax rate
`decimal(6, 3)`, and leave counts `decimal(6, 2)`. Two things are worth being
plain about:

- **Leave counts were never demonstrably broken.** Three significant digits sit
  well inside what a float holds, and `12.4`, `18.3` and forty half-days off a
  balance of `20.0` all round-trip exactly. They moved anyway, because a leave
  balance is a countable quantity compared for equality rather than a
  measurement — but the justification is consistency, not a failure.
- **The migration fixes writes, not history.** Whatever the float already
  rounded away is gone from the table. Rows written before it carry the loss.

Two findings came out of the same work and are recorded rather than counted as
defects, neither having a demonstrated failure behind it. `only_float: true`,
on four validations, does nothing at all — it is not an option Rails'
numericality validator recognises, so it is carried and ignored, and an
`Integer` or a `BigDecimal` validates exactly as a `Float` does. It is removed,
and the seed comment that cited it is gone. And `FLOAT_MAX`, the bound those
validations used, was `1e23` — above what `decimal(15, 2)` can hold, so a value
between the two would have reached MySQL and raised out-of-range instead of
failing validation. It is now `AMOUNT_MAX`, set to what the column takes.

Two rows are left in the backlog below. Neither was in this phase's checklist
and neither is reachable from ordinary use, so the phase closes here rather
than absorbing them; they are described where they sit.

---

## Phase 3 — Modernise the stack ✅

*Shipped.*

Ruby 2.7 and Rails 6.0 are both past end of life, and the original repo reports
132 dependency vulnerabilities. This is the largest phase, and it is also the
best interview story in the project — a real legacy upgrade with a test suite
underneath it, which is why it comes after Phase 1 rather than before.

- [x] Replace the `sequenceid` dependency, which was pinned to a branch on a
      third-party fork — if that branch disappeared the app stopped building.
      Done first, since it patched ActiveRecord STI internals and would have
      been an unknown in every step below
- [x] Ruby and Rails, interleaved. **The two cannot be done in sequence:**
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
      untested rather than safe. *(Expected here to go live on rspec-rails 6.
      It does not: 6.1.5 never mentions the executor, and
      `RSpec::Rails::RailsExampleGroup` includes selected Active Support test
      modules rather than inheriting from `ActiveSupport::TestCase`, so the
      load hook never reaches it. The query cache is still off inside an
      example. Corrected during the gem sweep, by probe rather than by
      reading.)*

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

The rspec-rails bump was expected to carry a consequence recorded during the
7.0 defaults step — that rspec-rails 6 would descend from
`ActiveSupport::TestCase` and make `executor_around_test_case` live. It does
not, and the expectation was wrong: rspec-rails builds its own example groups
and includes Active Support's test modules rather than inheriting the class, so
the load hook that installs the executor never reaches them. The query cache
stays off inside an example, and the tenancy interaction remains untested.

Ruby 3.3 cost nothing. No gem moved, the lockfile changed by one line, and the
suite, the asset build, the server and the worker all came up unchanged. Worth
recording precisely because the two Ruby steps before it were not like that:
3.0 needed bootsnap moved, and 3.2 needed capybara and mysql2. Nothing in this
app reaches for a stdlib method 3.3 changed, and nothing warns about the
default gems 3.4 will move out.

That closes the interleaved sequence. What is left of this phase is the gem
work the framework bumps were blocking.

- [x] Paperclip → Active Storage. Two attachments, `User#image` and
      `Department#avatar`, and the eight metadata columns they kept. Paperclip's
      `styles:` become Rails 7 named variants, so the sizes stay declared on the
      model rather than spreading into the three views that render them.

      The 7.0 framework defaults select the vips variant processor, so the image
      now installs `libvips42` explicitly. ImageMagick had been present all
      along but only transitively — nothing declared it, and variants would have
      depended on that accident.

      Declaring it in the Dockerfile was not enough: CI never builds that image,
      it runs on the runner, so the variant specs raised `LoadError` there while
      passing locally. The workflow installs it too, and cannot copy the
      Dockerfile's spelling — the image is Debian bookworm, where the package is
      `libvips42`, and the runner is Ubuntu noble, whose 64-bit `time_t`
      transition renamed the same package `libvips42t64`.

      No backfill task ships with it. The columns are dropped in a migration
      that says in its body why a deployment holding real uploads has to copy
      them out first: the file names live in those columns and nowhere else.
      This repository has none, so writing an untested backfill would have been
      worse than saying that plainly.

      One thing worth knowing rather than assuming: as shipped here,
      `active_storage_validations` checked the **declared** content type, not
      the analysed bytes. A text file renamed `.png` and sent as `image/png`
      passed. That matched what Paperclip did — it trusted the declared type
      and the file extension — so it was parity, not a regression, but it was
      not the guarantee the validation looks like it gives. The next item
      closes it.
- [x] Reject uploads by analysed content type rather than declared. `User#image`
      and `Department#avatar` now pass `spoofing_protection: true` to the
      content type validator, which runs `file -b --mime-type` over the
      upload's bytes and rejects it when the answer is neither the declared
      type nor one of its Marcel parents.

      That makes `file` a runtime dependency, and it had been arriving by
      accident: present in `ruby:3.3.12-bookworm`, declared in neither the
      Dockerfile nor the workflow. Both name it now — the same lesson as
      `libvips` one item above, applied before it could be learned twice.

      The check reads the whole upload into memory, which is what the gem warns
      about for large files. Bounded here by the 3 MB size validator both
      attachments already carry.

      The gem's copy for the three errors these attachments can raise read like
      library internals, so `en.yml` overrides them: "must be one of: PNG,
      JPG", "does not look like the image type it claims to be", "must be
      smaller than 3 MB". The specs assert the rendered strings as well as the
      error types, because `errors.details` does not interpolate — a broken
      `%{}` would pass a type-only assertion and raise on the page instead.
- [x] Stop the attachment specs writing libvips warnings into the CI log. The
      suspected cause was the oversized-upload example, which padded a real PNG
      with nulls to clear the 3 MB limit. It was not.

      `spec/fixtures/files/avatar.png` was itself corrupt: its `IDAT` chunk
      stored a CRC of `c32e5d45` against an actual `c8454b42`, and carried more
      image data than its 8×8 header declares. libvips repaired it on every
      read and logged `IDAT: Too much image data` and `IDAT: CRC error` each
      time — so every example touching the fixture was noisy, not just the
      padded one. Regenerated valid, 289 bytes, all four chunks checking out.

      The oversized upload is now a genuine 1200-square PNG of random pixels
      rather than a padded file. PNG cannot compress noise, so it encodes to
      about 4 MB in roughly a tenth of a second, and nothing has to reason
      about whether a decoder tolerates trailing bytes.
- [x] Webpacker 5 → `jsbundling-rails` with esbuild. Sprockets was already
      compiling the stylesheets, so this collapses two pipelines into one:
      esbuild writes to `app/assets/builds` and Sprockets fingerprints and
      serves it. Propshaft plus importmaps was the alternative and was not
      taken — select2 and Bootstrap's JS are npm-shaped dependencies that
      importmaps would have meant vendoring by hand, which is a rewrite rather
      than a bundler swap.

      What it bought: Node 14 → 24 and webpack 4 → esbuild, so `yarn audit`
      goes from **76 vulnerabilities, 2 critical and 42 high** to a supported
      toolchain. The chain of workarounds propping up Node 14 is gone with it —
      the sass pin in `package.json`, the `--ignore-engines` flag, and the
      comment explaining why the Node tarball had to be fetched by hand.
      `application.js` is 592 KB minified against webpack's 782 KB.

      Two things surfaced while doing it, both only visible in production:

      Font Awesome came through the JS bundle as a CSS import. esbuild
      content-hashes the font files, Sprockets then fingerprints them again,
      and the URLs esbuild wrote point at names that only exist undigested — so
      every icon 404s once assets are precompiled, while looking correct in
      development. It now comes from `font-awesome-sass`, which uses Sprockets'
      `font-path` helper, so the digests match. Checked by precompiling for
      production and confirming every referenced file exists.

      `application.scss` already carried
      `@import "@fortawesome/fontawesome-free/css/all.css"`, which Sprockets
      could not resolve and emitted as a literal CSS `@import` to a path that
      404s. It had never worked; the icons were coming from webpack. Removed.
- [x] Bundle select2 and AOS instead of loading them from public CDNs. All
      three sat in `package.json` unused while the layout and landing page
      fetched them from jsdelivr, cdnjs and unpkg — a third-party runtime
      dependency for an HR application, and the AOS versions did not even match
      between the pin and the CDN URL. AOS now serves the 2.3.4 that was
      pinned, rather than the 2.3.1 the URL asked for.

      The JavaScript goes through esbuild, the CSS through Sprockets as a plain
      `@import` — `node_modules` is already on the asset load path and
      `bootstrap/scss/bootstrap` was importing from it the same way. Importing
      the CSS from JavaScript instead would have had esbuild emit
      `app/assets/builds/application.css`, giving Sprockets two candidates for
      one logical path, since `manifest.js` links both that tree and the
      stylesheets directory.

      The Bootstrap theme was dropped rather than bundled, and removed from
      `package.json`. It only defines `.select2-container--bootstrap`, and the
      single `.select2()` call asks for `theme: "classic"`, whose 38 rules ship
      in select2's own stylesheet. Nothing has ever carried the `--bootstrap`
      class, so the CDN was fetching a stylesheet that could not apply and
      bundling it would only have moved unreachable CSS into `application.css`.
- [x] Clear the three gems that blocked Rails 7.2. searchkick 4.6 → 5.5, devise
      4.9 → 5.0 and rspec-rails 5.1 → 6.1 each called something 7.1 deprecates
      and 7.2 removes. The suite now runs with no deprecation warnings at all.

      searchkick 5 dropped its dependency on a client gem, so `elasticsearch`
      is now declared here and pinned to the 7.x line the compose file and CI
      run — the fear that this forced an Elasticsearch 8 server was unfounded.
      Search reaches Elasticsearch before Active Record, so it is the one read
      path where tenancy rests entirely on the default scope applied when ids
      are loaded; it now has a spec saying so, written before the bump.

      **Upgrading an existing deployment needs a reindex.** searchkick 5 changes
      the index mapping and refuses one written by 4 with `Bad mapping - run
      reindex`. A fresh clone is fine, because seeding creates records and the
      save callbacks index them. Note the trap when reindexing here: a bare
      `Model.reindex` runs `Model.all`, which the tenancy default scope narrows
      to the current tenant — with none set it indexes nothing and silently
      swaps in an empty index. Reindex inside each company in turn.
- [x] Clear the remaining Dependabot backlog, which was one advisory rather
      than the twelve the repository reported.

      It read 92 before phase 3 was released. Alerts are computed against the
      default branch, and `main` was 49 commits behind — still Rails 6.1.7.10,
      puma 4.3.8 and Webpacker 5 — so most of them described code that had
      already been deleted. Releasing dropped the count to twelve.

      **A stale default branch hides as much as it invents.** Dependabot
      matches advisories against the version in the manifest, so while `main`
      said puma 4.3.8 it reported the 4.x advisories and said nothing about the
      6.6.1 that `develop` was actually running. Two alerts ranged
      `>= 5.5.0, < 7.2.1` appeared within hours of the release, masked until
      the manifest caught up with the code. Neither applies — both are PROXY
      protocol v1 issues, the protocol is opt-in in puma, and nothing here
      enables it.

      Eleven of the twelve need a configuration this app does not have: direct
      uploads, proxy mode, PROXY protocol, user input used as blob keys, or
      number helpers over user strings. `number_to_currency` here runs only
      over numeric payroll columns.

      The one that lands is
      [GHSA-xr9x-r78c-5hrm](https://github.com/advisories/GHSA-xr9x-r78c-5hrm),
      CVSS 9.5: arbitrary file read and remote code execution through Active
      Storage variant processing. It affects any application on the vips
      variant processor that accepts image uploads from untrusted users, and
      states that generating variants is not a separate requirement.
      `config.load_defaults 7.0` selects vips and nothing overrides it, so this
      is the shape of this app exactly.

      There was no fix on the 7.1 line — 7.1.6 is its last release and the
      patches shipped as 7.2.3.1 and 7.2.3.2 — and `activestorage` cannot be
      raised on its own. The remedy was Rails 7.2, which the gem sweep above
      was done to unblock. Done in the item below; all ten Rails advisories
      were ranged `< 7.2.3.1` or `< 7.2.3.2`, so the one bump closes every one
      of them rather than only the critical.

      The two puma alerts are left open deliberately. Both are PROXY protocol
      v1 issues ranged `>= 5.5.0, < 7.2.1`, the protocol is opt-in, and nothing
      here enables it — clearing them means a major version of the application
      server for something that cannot fire.

      **Reversed, and taken anyway.** The reasoning above still holds on its
      own terms — neither advisory can fire here — but it priced the two
      sides wrong. Phase 4 puts this application on the public internet, and
      the process facing it is the last one to leave two majors behind on a
      technicality. Taken to puma 8.0.2, which neither range covers.

      Verified by booting it rather than by a green suite, because the suite
      never starts puma: 8.0.2 boots under Ruby 3.3.12 with YJIT, and a
      cold `curl` sign-in as `owner@example.com` reaches an authenticated
      dashboard scoped to Acme Corporation. That exercises the server, the
      session cookie and subdomain tenant resolution together, which is the
      part a version bump could plausibly break.

      7.2.1 was the smaller option — it is the patch release both ranges end
      at, published a day after 8.0.2 — and it would have cleared the alerts
      just as well. It crosses a major either way, so it buys nothing except
      a shorter distance to the next one.

      Releasing phase 3 produced twelve fresh Dependabot PRs, the first run
      against `develop` under the configuration added earlier in this phase.
      Eleven were green, which is worth less than it reads: there are no
      system or browser specs here, so a passing run is evidence only about
      what CI reaches. They were split on that line: the four CI genuinely
      exercises were taken, puma was taken and verified by booting it, the one
      that proposed raising a gem nothing uses was answered by deleting the
      gem instead, and the five front-end updates were held for verification
      that can see them. The twelfth is Rails 8.1, which is a phase and not
      a bump.

      One of the five closed itself shortly afterwards. `@rails/actioncable`
      went with the Webpack channels entry recorded in the defect backlog
      below, leaving four.

      The verification those four were waiting on now exists — the system
      specs in the phase 1 amendment assert the globals jquery, select2,
      bootstrap and chartkick each leave on `window`, and fail on an uncaught
      exception in the page. That is not the same as having verified them. The
      specs reach three pages, and a major of any of the four can break a
      fourth page they never load. Taking them means extending the specs to
      whatever each one touches, which is work per PR rather than a rerun.

      **select2 taken**, `4.1.0-rc.0` to `4.1.0` — a release candidate that had
      been pinned since 2021 going to the release of the same number. Extending
      the specs first is what the sentence above asked for, and it turned up
      that the HR leave form is the only place select2 is attached to a real
      element. Three examples now drive it: the control replaces the select,
      typing in its search field appends what the request finds, and picking a
      result fires `select2:select`, which is select2's own event rather than a
      DOM one and only reaches its handler if the library is driving the
      element. Getting those right took two attempts — the first raced the
      per-keystroke AJAX against select2's re-render and passed or failed on
      timing. A test that green-lights a dependency bump by accident is worse
      than no test, so it waits for the append and types once more.

      **`@rails/activestorage` taken**, `6.0.0` to `7.2.302`, matching the Rails
      it ships beside. **`@rails/ujs` went with it**, `6.0.0` to `7.1.600`,
      which Dependabot did not raise: 7.1.600 is the last release, because
      Rails 8 removes the package. Holding it at 6.0.0 while its sibling moved
      to 7.2 widens a mismatch rather than leaving one alone.

      **chartkick taken**, and it is the one that was never a bump. chartkick.js
      5 declares `chart.js: "4"` as a peer, so Chart.js crosses a major with it
      and `chartjs-adapter-date-fns` and `date-fns` arrive behind it. The gem
      moves too — it was pinned `= 4.0.5`, and the gem renders the tag the npm
      package draws into, so a gem that predates the drawing code is the same
      class of mismatch as holding `@rails/ujs` back. Four npm packages and one
      gem in one step, because splitting them leaves a commit that cannot run.

      The analytics page is what made this checkable. It is the only page
      carrying both shapes chartkick offers — one chart handed its data inline
      by the view, one given a path and left to fetch it — and it had no spec,
      so the dashboard's two remote charts were the whole of the coverage. It
      has one now, asserting both canvases and the absence of the message
      chartkick writes into the container when it cannot draw. Both pages were
      also looked at, because a canvas element existing is not the same as a
      chart being on it: the stacked column, the line with its currency prefix
      and rotated month labels, and the dashboard's two all render.

      **jquery taken**, 3.6.0 to 4.0.0, and it is the one that found something.
      Six pages load a bundle of their own and none of them were covered, so
      they were specced first — each asserting the one thing its bundle does,
      rather than that the page still renders. That surfaced three `$.ajax`
      calls asking for `dataType: 'script'` from endpoints that answer
      `format.json` and then running `JSON.parse` over the result: the employee
      search and the leave-type cascade on the HR leave form, and the
      department-to-designation cascade on the employee form.

      They were never right. jQuery 3 sent `*/*` alongside `text/javascript`
      in the Accept header, Rails fell back to JSON on it, and the response
      came back as text that `JSON.parse` was happy with. jQuery 4 dropped the
      wildcard, so Rails has nothing to negotiate and the request 404s. No
      exception is thrown anywhere — the failure is a select that stays empty,
      which is why nothing had noticed and why `js_errors` alone would not
      have caught it either. All three now ask for JSON and read what they are
      given.

      The seven remaining `dataType: 'script'` calls are correct: those
      endpoints render `.js.erb` templates and answer `format.js`.

      `jbuilder`, `capybara`, `selenium-webdriver` and `webdrivers` had no
      reference anywhere in `app`, `lib`, `config`, `spec`, `bin` or `db`,
      and no `.jbuilder` template exists. The system-test trio arrived with
      `rails new` in 2021 and was never used; `webdrivers` has had no
      upstream commit since January 2024 and pinned `selenium-webdriver` below
      4.0. Removing them takes ten gems out of the lockfile, four direct and
      six pulled in behind them. If system specs are written, they will want
      a current Capybara and a driver strategy chosen then, not a 2019
      Selenium held in place by a Gemfile.

      They were, in the phase 1 amendment above: capybara 3.40 and cuprite,
      eight gems back into the lockfile against the ten that came out. The
      driver strategy chosen then was CDP rather than a driver binary, which
      is the coupling `webdrivers` had been pinning around.
- [x] Rails 7.1 → 7.2. Held on `config.load_defaults 7.0`: the version bump and
      the framework defaults are separate steps, because the defaults are where
      behaviour changes and the bump is what carries the security fix.

      Pinned `'~> 7.2.3', '>= 7.2.3.2'`. The lower bound is not decoration —
      `~> 7.2.3` on its own resolves to 7.2.3, which is below the patch.

      The `delayed_job < 4.2` pin came off, as its own comment said it should.
      Nothing in the app calls `perform_later`, so the suite passing proved
      nothing about it; checked directly instead. 4.2.0's adapter does shadow
      the one Rails ships, exactly as the pin described, and it now subclasses
      `ActiveJob::QueueAdapters::AbstractAdapter`, which 7.2 added — so the
      shadowing is harmless and enqueueing works.

      7.2 also surfaced one new deprecation, `ActiveSupport::ProxyObject` from
      jbuilder 2.11.2, removed in Rails 8. jbuilder 2.15.1 uses `BasicObject`
      and the suite is back to no deprecation warnings at all. Worth noting
      that jbuilder is unused here — no `.jbuilder` template and no reference
      to it anywhere in `app/`.
- [x] Enable the Rails 7.1 framework defaults. `config.load_defaults 7.1`
      replaces `new_framework_defaults_7_1.rb`, which is deleted. No failures
      and no deprecations.

      The staged file's own annotations were checked rather than taken on
      trust. Its list of flips that cannot reach this app holds: no `serialize`d
      column, no `attr_readonly`, no `has_secure_token` and no `after_commit`
      anywhere in the Ruby or ERB source.

      One annotation was wrong. It singles out
      `active_job.use_big_decimal_serializer` as "the one job-serialisation
      flip with something to bite here", because payroll works in BigDecimal
      and enqueues through delayed_job. Payroll's money columns are `t.float`,
      not `t.decimal`, so they arrive as `Float`; all five `.delay` calls pass
      integer ids and nothing else; and `.delay` is delayed_job's own API
      rather than Active Job, so the setting would not reach them regardless.
      It has nothing to land on.

      One leg of that has since gone: the money columns are `decimal` now, so
      payroll does arrive as `BigDecimal`. The conclusion is unchanged — the
      `.delay` calls still pass integer ids and `.delay` is still not Active
      Job — but the first reason no longer holds.

      `commit_transaction_on_non_local_return` is no longer a setting to
      enable. Rails 7.2 deprecates it and 8.0 removes it, having made the 7.1
      behaviour unconditional, so reading it now emits a deprecation. Taking
      the version bump first turned one of this file's options into a no-op
      before it was ever switched on.

      Confirmed applied rather than inferred from a green suite, which covers
      no views: `ActiveSupport::Cache.format_version` and
      `marshalling_format_version` both 7.1, `raise_on_assign_to_attr_readonly`
      true, `belongs_to_required_validates_foreign_key` false,
      `generate_secure_token_on` `:initialize`,
      `dom_testing_default_html_version` `:html5`, `message_serializer`
      `:json_allow_marshal`, and `X-Download-Options` gone from the default
      headers.
- [x] Enable the Rails 7.2 framework defaults. Four settings against the 7.1
      set's twenty-three, and only one of them does anything here.

      `postgresql_adapter_decode_dates` cannot apply — this is MySQL.
      `validate_migration_timestamps` governs migrations written from now on
      and does not revisit the 41 already committed.
      `active_job.enqueue_after_transaction_commit` has nothing to act on:
      nothing calls `perform_later`, and all five enqueues go through
      delayed_job's own `.delay`.

      `active_storage.web_image_content_types` gains `image/webp`, and it is
      inert for a reason worth stating rather than assuming: the attachment
      validators on `User#image` and `Department#avatar` accept `image/png` and
      `image/jpeg` only, and they reject before Active Storage decides how to
      treat the bytes. Nothing webp can ever be attached to widen.

      `yjit = true` is the one with runtime effect, and it is real rather than
      a silently unavailable flag: YJIT is compiled into the `ruby:3.3.12`
      image and `RubyVM::YJIT.enabled?` reports true once the app has booted.
- [x] Revisit the `TracePoint` multi-tenancy hook against modern Rails
      autoloading. It is sound on Rails 7.1 under Zeitwerk: `Company` stays
      unscoped, every other model carries the `company_id` condition, and an
      unset tenant produces `company_id IS NULL` rather than an unscoped query,
      so it fails closed. Nothing about autoloading needed changing.

      The review did turn up that the `TracePoint` is no longer *necessary*.
      It exists to defer the `default_scope` until the end of the class body,
      because `inherited` runs before `set_not_multitenant` has had a chance
      to. A `default_scope` block is evaluated per query rather than at
      definition, so moving the test inside the block does the same job:

      ```ruby
      subclass.instance_eval do
        default_scope { subclass.multitenant? ? where(company_id: Company.current_company_id) : all }
      end
      ```

      Tried, and behaviourally identical — same SQL for scoped, unscoped and
      no-tenant cases, whole suite green. Not applied: this is the load-bearing
      mechanism of the application and the candidate write-up in phase 6, so
      swapping it is a decision rather than a tidy-up. Recorded here so it is a
      choice rather than an unknown.

      **Applied afterwards, and "it is sound" above was wrong.** Returning to it
      with the hook itself under test turned up three faults. None changes a
      query, which is why nothing had noticed:

      - `trace.disable` sits inside the branch that installs the scope, so a
        model calling `set_not_multitenant` never disables its own hook.
        `Company` has leaked one enabled process-wide `:end` TracePoint per
        boot and one more per code reload — 2 rising to 7 across five reloads.
        There is no runtime cost to point at: 2,000 class bodies took 0.014s
        with none enabled and 0.015s with one.
      - `return if ENV['skip_default_scope'].present?` returns *before*
        defining `set_not_multitenant` on the subclass, so setting the variable
        does not skip the scope, it stops boot with `undefined local variable
        or method 'set_not_multitenant' for class Company`. Referenced nowhere
        else, and it can never have worked. Removed rather than repaired:
        `unscoped` already covers the need, and a process-wide switch that
        silently disables tenant isolation is the wrong thing for this
        application to own.
      - `:end` is only emitted by a `class ... end` body. A model built with
        `Class.new(ApplicationRecord)` was handed no default scope at all —
        `SELECT * FROM departments`, no condition. Nothing here is defined that
        way so nothing was exposed, but in that case the mechanism failed
        **open**, in the same paragraph that claims it fails closed.

      The replacement is the block above. Same SQL for the scoped, unscoped,
      no-tenant and opted-out cases, compared side by side. One difference worth
      knowing: `Company` now carries a default scope that evaluates to `all`
      where it previously carried none, so `Company.default_scopes` is 1 rather
      than 0. Its SQL is unchanged and `Company.new` still sets no attributes,
      tenant set or not.
- [x] Search reported a hit count from an Elasticsearch index that is not
      partitioned by company. The query now carries the tenant filter itself,
      in `TenantSearch`, rather than leaving tenancy to the default scope
      applied when the ids come back.

      `company_id` was already in the mapping — searchkick indexes
      `serializable_hash` unless a model overrides `search_data` — so this
      needed no reindex. A nil tenant filters to documents with no
      `company_id`, of which there are none, so an unset tenant finds nothing
      rather than everything, the way the default scope fails closed. See the
      defect backlog

**Done when:** the suite passes on Rails 7.1 and Ruby 3.3, and no dependency is
pinned to a git branch. Both hold, and the framework went one further than the
line called for — 7.1 could not stay, because 7.1.6 is the end of its line and
the Active Storage advisory has no fix there.

---

## Phase 4 — Live demo

Estimated 3–5 days. **Now sequenced after phase 7** — see the note at the end
of this file, which reverses the argument this document opens with.

Most people who open the repo will never run it. A URL they can click, sign
into as four different roles, and poke at is worth more than any amount of
README prose.

- [x] **Rails 7.2 before anything here.** Deploying is what supplies the
      precondition for the Active Storage advisory recorded in phase 3 —
      untrusted users able to upload an image — and this phase ends by printing
      sign-in credentials on the landing page. Done in phase 3
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

- [x] Architecture diagram in the README showing subdomain → tenant scope →
      query. A mermaid flowchart, which GitHub renders natively, replacing the
      ASCII sketch that was there. It carries two things the sketch could not:
      the branch where an unset tenant compiles to `company_id IS NULL` and
      matches nothing, and the opt-out branch `Company` takes
- [x] Screenshots or a short capture of the leave approval flow —
      [docs/leave-approval-flow.md](docs/leave-approval-flow.md). Four screens
      in order: an employee applying, the request landing as pending, the
      company-wide queue HR sees, and the same queue after approval. Captured
      by driving a real browser and signing in as each role, which is how the
      twenty-fourth defect turned up
- [x] A short write-up of one hard problem and how it was solved —
      [docs/tenant-isolation.md](docs/tenant-isolation.md). The `TracePoint`
      hook, the three faults it carried, and why a green suite and a close
      review both missed them: every fault was in a path nothing exercised —
      opting out, an environment variable nobody sets, and a model defined with
      `Class.new`. The SQL comparison in it was run against the app rather than
      recalled
- [ ] Keep the README's "Known gaps" section honest as items get closed

---

## Phase 7 — Rebuild the interface

Estimated 2–3 weeks. Runs before phase 4.

Every other phase has touched something. This one has not been touched at all:
the interface is the 2021 original, and it is the first thing anybody sees.

The problem is not that Bootstrap is the wrong framework. It is that Bootstrap
was never configured. `@import 'bootstrap/scss/bootstrap'` pulls the whole
default theme in and nothing overrides a single variable, so the app looks like
the framework's documentation. Underneath that sit 693 lines of SCSS holding
**22 hex colours picked one at a time**, one SCSS variable, and no scale of any
kind. There is no component layer either: **49 views hand-write `btn btn-*`,
20 hand-write `.card`, and 18 hand-write a `<table>` from scratch**.

### What was considered

Four options, decided on 31 Aug 2026.

| | Approach | Why not |
| --- | --- | --- |
| A | **Hotwire + ViewComponent + Bootstrap 5.3, themed** | *Chosen* |
| B | Hotwire + ViewComponent + Tailwind | Roughly double A for a similar result: a utility rewrite across 121 views, a select2 replacement, and restyling what simple_calendar, chartkick and will_paginate emit |
| C | Inertia + React | Rewrites all 121 views including devise's 16, moves the 22 views that call `can?` into serialized props, and replaces will_paginate, simple_calendar, breadcrumbs and the chartkick helpers |
| D | Full SPA on a JSON API | Needs the API phase 5 lists as unbuilt, plus devise moved to token auth. Stops being a restoration |

One thing the table does not capture: A is the only option that ends with
jQuery gone. Under it select2 is replaced rather than carried, which is what
lets `jquery` leave `package.json` entirely — see the item below.

The deciding argument is that **the design system is the ViewComponent layer,
not the CSS framework**. Tokens, a component set, and a preview page are the
same work under A or B; picking Bootstrap 5.3 underneath only makes it cheaper
and keeps five ERB-coupled gems alive — devise, will_paginate, simple_calendar,
breadcrumbs_on_rails and chartkick's helpers.

### The work

- [x] **Tokens before anything else.** `_tokens.scss` holds the ramps, type
      scale, spacing, radius and shadow, and `_bootstrap_theme.scss` sets
      Bootstrap's variables *from* them — imported before the framework,
      because every one of those variables is `!default` and the first
      assignment wins. Importing it afterwards would have changed nothing
      while looking like it configured everything, which is roughly what the
      app was doing already.

      Bootstrap 5.0.2 → 5.3.8 rode along, and the pipeline turned out not to
      need touching: `sassc` is libsass, dead since 2021, but it compiles 5.3
      fine — 449 `--bs-` custom properties and the colour-mode blocks all
      present in the output. Replacing it with dart-sass is worth doing and is
      not blocking, so it is not done here.

      All twenty-two colours are gone from the stylesheets, including the
      separate palette the landing page kept — a cyan, a navy and two greys
      that appeared nowhere else. Mapping it onto the shared ramps is the point
      of the step: a second palette is a second system
- [ ] **ViewComponent, and Lookbook in front of it.** Started: `Button`,
      `Badge`, `Card`, `Table`, `PageHeader` and `EmptyState` exist with a
      preview each, and the HR leave queue is converted as the proof. `FormField`
      and `Modal` have landed since, so the set the phase named is complete and
      what is left is views rather than components.

      Every component stamps `data-component` into its markup, and the system
      specs key off that rather than off Bootstrap's class names — so restyling
      a component cannot break a spec that was only ever asking whether the
      thing is on the page. That was recorded as a cost of this phase; doing it
      per component as they land is what stops it becoming one.

      `TableComponent` wraps the shell and not the data. Eighteen views build a
      table by hand and every one has a different row, so what they share is the
      chrome; forcing a column API onto them would be a rewrite wearing a
      component's name.

      `FormField` is in, and it earned itself immediately. 34 labels across 12
      views called `form.label t('forms.labels.x')`, which Rails reads as the
      attribute name: every one wrote `for="user_Email"` against an input with
      id `user_email`. The text was right and the association was not, so the
      label focused nothing and a screen reader announced the field unlabelled.
      The component takes the attribute and the text separately, so the mistake
      is not expressible through it — and the eleven views not yet converted had
      the association fixed in place rather than waiting for the migration.

      Two things worth knowing. Previews render inside the app's default layout,
      which reaches for `current_user` — every one of them 500s until a bare
      preview layout is configured, and that was found by opening Lookbook
      rather than by any check. `spec/components/previews_spec.rb` renders every
      scenario now and does catch it: removing the layout config fails all ten.
      And Lookbook is development-only, so whether the demo exposes the previews
      is a phase 4 question, not settled here
- [x] **Turbo replaces turbolinks.** The line above priced this as a rename,
      and the renames were the smallest part of it. `turbolinks:load` becomes
      `turbo:load` in two files, and `data-turbolinks-track` becomes
      `data-turbo-track` in the seven places it sits in a `<head>` — it is
      dropped from the seven where it does not, because Turbo compares tracked
      elements between head snapshots only, so the attribute on a body script
      was configuring nothing while looking like it configured something.

      What the rename does not cover is that **Turbo Drive intercepts form
      submissions and turbolinks did not**, and it throws away a 200 answer to
      one without rendering it. Nine actions re-render a form with its errors
      and every one answered 200 — including, a layer down, Devise, which still
      defaults `error_status` to `:ok` for apps predating Turbo and whose
      initializer here is from 2021. Left alone, a wrong password would have
      answered with a body the browser never draws: the sign-in page sitting
      unchanged, no message, nothing in the console either. All nine now say
      `:unprocessable_content` — not the `:unprocessable_entity` every Rails
      guide writes, which Rack 3.2 deprecates and warns on.

      `redirect_status` goes to `:see_other` beside it, as precaution rather
      than a fix, and the distinction is worth recording because the usual
      explanation of this setting is wrong. fetch downgrades a redirect to GET
      only when the request was a POST, so a genuine PATCH answered with 302
      would come back as a PATCH — but no Rails form can produce that.
      `form_with method: :patch` renders `method="post"` with a hidden
      `_method`, which is what the settings form does when you read it off the
      page. It becomes reachable only when a link carries `data-turbo-method`,
      which Turbo does put on the wire literally.

      **No `turbo-rails` gem.** It was taken first, on the assumption its Ruby
      side was carrying something — a 303 default on redirects, or the mime
      type registration that keeps the `Accept` header Turbo sends on every
      form submission out of trouble. Neither holds: the gem has no redirect
      patching in it at all, and with it removed the whole system and request
      suite still passes, Turbo form submissions included, because Rails reads
      past an unregistered type in `Accept` and answers the `text/html` behind
      it. It goes back in when something here renders a `turbo_stream`, which
      is the Stimulus step. The JavaScript comes from npm through esbuild like
      everything else in the bundle.

      **rails-ujs stays**, and keeps driving the `data-method` links and the
      `.js.erb` responses until jQuery leaves. Both libraries want the same
      clicks, and what keeps them apart is structural rather than lucky: ujs
      delegates on `document` while Turbo's link observer is on `window`, so
      ujs sees a click first and stops it propagating; and Turbo's form
      observer ignores any submit whose default was already prevented, which is
      what ujs does to a remote form. A system spec deletes a department
      through a `data-method` link so that stops being an argument.

      Two things this turned up that no amount of reading would have.

      **The suite was green before any of it was true.** All 292 examples
      passed with turbolinks swapped for Turbo underneath them and would have
      passed with neither, because every system spec `visit`s rather than
      navigates, and a `visit` is a full page load whichever library is on the
      page. The seven examples in `spec/system/turbo_spec.rb` exist to make the
      swap falsifiable, and each was checked by breaking the thing it covers:
      without the Turbo import both navigation examples go red, with
      `settings#update` back at 200 the error render vanishes with no message
      anywhere, with Devise back on `:ok` the sign-in page answers a wrong
      password with nothing at all. One drafted example asserted the form was
      still on the page after a failed submission — it passed against the bug,
      so it is not in the file.

      **`sign_in_as` had to learn to wait, and the whole system suite runs on
      it.** A native form submission blocks the browser until the next document
      exists; Turbo submits with fetch, so `click_on` returns while the visit it
      started is still in flight, and the `visit` after it raced Turbo — which
      landed afterwards and replaced the page the example was about to work on.
      It failed about one run in three, on whichever example got there first,
      and it read as `fill_in` failing to find a field that is plainly on the
      page it asked for. Found by running the new file eight times rather than
      once, which is now the habit for anything that navigates.

      One defect, in the backlog below: Turbo caches a snapshot of the page it
      is leaving and restores it on a back navigation, and select2 injects its
      control as a sibling of the select it wraps — so the snapshot carried the
      control and the bundle re-running on restore built a second one beside it.
      Two stacked dropdowns over one select. Attributed rather than assumed: the
      same probe against develop under turbolinks reports one container either
      way, so it arrived with Turbo
- [ ] **Stimulus replaces jQuery.** Twelve entry points, roughly 360 lines.
      Started: the seven with no AJAX in them are six controllers, and jQuery
      is still here for the five that have.

      Six rather than seven because two pairs were the same behaviour written
      twice. `user_leaves.js` and `users_benefit_creation.js` both enabled the
      field beside a ticked checkbox, and found that field differently — one
      kept a CSS selector in a data attribute, the other an element id, and
      neither could be read off the markup. And `signup.js` was character for
      character the top of `user.js`, which is bundled into `application.js`
      and therefore ran on every page: on the one page with a `#company` field
      the slug was computed twice and written to the same two elements, which
      is why neither copy was ever noticed. "One controller each" was the wrong
      unit — the right one is one controller per behaviour.

      Registrations are written out by hand in `controllers/index.js` rather
      than swept up from the directory. The helpers that do the sweeping read
      an importmap or a webpack `require.context`, and the second of those is
      the defect that threw on every page of this application for two releases
      after the esbuild migration. esbuild resolves imports statically, so a
      name that is wrong here fails the build.

      What this buys beyond the framework swap is that the per-page bundle goes
      away: seven `javascript_include_tag` calls are gone from views, and with
      them the arrangement recorded during the Turbo work where a body bundle
      is re-executed on every visit and its document-level handlers accumulate
      one copy per navigation.

      The controllers set no initial state on connect. The disabled fields and
      the disabled submit are rendered disabled, so a browser that never runs
      the JavaScript still gets what the server meant; `toggle-field`'s
      `connect` only re-syncs, which is what a Turbo cache restore needs.

      Three dead things fell out of auditing what the bundles touched. Nothing
      in this application carries `data-toggle="tooltip"` or
      `data-toggle="popover"`, so the initialiser `application.js` ran on every
      page load selected nothing — removed rather than converted. The one
      `data-toggle` that does exist is a tab in Bootstrap 4's spelling, which 5
      has not read since the framework moved, on a one-item strip with no pane
      behind it, so renaming it would point Bootstrap at something that is not
      there; it is a heading styled as a tab and is a `span` now. And
      `layouts/_navbar.html.erb` is rendered by nothing — only
      `shared/_dashboard_navbar` is, and the two had drifted apart.

      The sidebar collapse was rewritten rather than transcribed, because it
      did not toggle a class, it swapped one: `home-content` came off and
      `sidebar-toggle` went on, so after a click the class the stylesheet keyed
      off had left the document, and the two rules behind them repeated four of
      their six declarations. One `expanded` modifier on each half replaces
      both. Reviewed as screenshots in both states, which is also how a
      font-load race was told apart from a regression — the first capture had
      no icons in it because Sprockets was still compiling the webfonts.

      `spec/javascript/bundling_spec.rb` strips comments before scanning. It
      greps source text for `require.context`, and `controllers/index.js` is
      exactly the file with a reason to name that defect in the comment
      explaining itself. Checked that it still fails on a planted call.
- [ ] **The `.js.erb` responses go.** Nine templates and five entry points that
      fetch one and eval it. Started: the employee, leave and event lists are on
      Turbo Frames, which is four of the nine gone.

      **Frames rather than Streams for a list.** A Stream is for updating
      something the request did not come from, or more than one thing at once.
      A filter or a page link is neither: the list is where the click came from
      and the list is what changes, so wrapping it in a frame means the server
      answers with the ordinary HTML page it already renders and Turbo takes the
      part that matters. No template per response, and `format.js` comes off the
      action.

      Turbo Drive alone would satisfy most of this, and it is worth being exact
      about what the frame adds rather than taking it on faith. It replaces only
      the list: the sidebar, navbar and notification badge around it are left
      alone, where a Drive visit re-renders the whole body and re-runs the count
      request on every keystroke. That is the one thing the specs assert about
      the frame specifically — the other three employee-list examples pass
      without it, which is correct, because filtering and linking and resetting
      are behaviour rather than mechanism.

      The filter form moves inside the frame so a navigation re-renders it and
      the fields echo their params. That is what lets the reset link point at
      the unfiltered URL instead of clearing inputs by hand, and it makes a
      filtered list a URL you can send someone. Filtering is debounced: the old
      handler fired one request per keystroke, which under
      `data-turbo-action="advance"` would be one history entry per keystroke.

      `turbo-rails` comes back for `turbo_frame_tag`, which is the condition the
      Turbo step set when it took the gem out.

      **Four defects, and the reason none of them was caught.** Nothing in the
      suite rendered `/members`, `/leaves` or `/events`. All 301 examples passed
      while three of the application's main pages answered 500 mid-change, and
      that is also why the four below survived. `spec/requests/index_pages_spec.rb`
      now GETs all ten index pages, empty and populated, which is twenty cheap
      examples that would have caught every one of them.

      The events index nested the whole table inside the link to the calendar.
      An anchor cannot contain another, so the parser split it into six, and the
      page rendered as four empty pill outlines with the table squeezed into a
      column beside them. It also called
      `render partial: 'no_events.html.erb'`, which Rails reads as a partial
      *named* `no_events.html.erb`, so the page 500d for any company with no
      events — the first thing a new tenant sees there.

      The leave index rendered no pagination while the controller paginated to
      `PAGE_SIZE`, which is 5, so a sixth leave type could not be reached. Its
      `_leaves_list` partial does carry pagination but was rendered by nothing
      except the dead `.js.erb` beside it, and had drifted to an older style, so
      the index keeps its own table and gains the control.

      `leaves/index.js.erb` and `events/index.js.erb` were both dead —
      `events#index` answers html only, and both targeted ids no page has ever
      contained — and the `.leave-pagination-wrapper` handler in
      `application.js` was the same story in JavaScript, bound on every page
      against a class no view carries.

      **The notification list went with them**, and it needed the disagreement
      between its two branches settled first: `format.html` answered with the
      unread notifications and `format.js` with whatever `params[:status]`
      asked for. A frame makes both the same request, so there is one branch
      now, honouring the parameter and defaulting to unread — which is what the
      page showed on load before, except that the bundle then had to force the
      select to match it.

      Marking as read gave no feedback at all. The button fired an `$.ajax`
      POST with no success handler, so rows were marked read in the database
      and stayed on screen until something else reloaded the page. It is an
      ordinary form submission now — associated by id, since the button sits in
      the header card rather than inside the form — and the redirect it already
      answered with reloads the list. Confirmed by answering `head :ok` instead
      and watching the original behaviour come back.

      **The HR leave queue is the one place a stream is the right answer.**
      Filtering and pagination are a frame like the others. Mass approve and
      reject are not: they change the table and the flash message, the flash
      sits outside the frame the click came from, and the request is a PATCH.
      Two targets off a non-GET is exactly what a stream is for, and it is
      worth having one case that earns it rather than reaching for streams
      everywhere.

      The confirmation had never been shown. `approve_leaves.js.erb` wrote the
      flash into `$("#flash_message")`, and no element with that id exists
      anywhere in this application — so the message counting how many of the
      selected requests actually changed state, which is the one that matters
      when some of them fail, went into an empty selection every time. The
      layout carries the container now, and it is what the stream updates.

      `filter_applied_leaves` is gone, action and route: filtering is
      `all_applied_leaves` with a `filter_type` param, which is what the frame
      navigates to, so the separate endpoint had nothing left to do.

      Two behaviour changes rather than defects. The buttons were behind
      `d-none` and revealed only when *more than one* row was checked, so
      checking exactly one left the page looking inert; they are visible and
      disabled until something is selected, matching the notification list.
      And the queue keeps its filter across a mass update through a hidden
      field rather than by reading the select back out of the DOM.

      **The modal and the calendar close the item.** Nine templates that
      returned JavaScript for the browser to eval are zero, and every
      `remote: true` link and `dataType: 'script'` call in the application went
      with them.

      The calendar is a frame around the month with the previous and next links
      naming it. The modal is a frame the edit links target, a stream on success
      that updates the list, clears the frame and writes the flash, and a 422
      re-render on failure that puts the errors back in the dialog. It replaces
      a flow that rendered the dialog with `$("#modal").html(...)`, called
      `.modal("show")`, and answered a successful save with
      `render js: "window.location = ..."` — a full page reload written as a
      string of JavaScript.

      **Bootstrap's Modal is not used, and that is a decision rather than an
      oversight.** It resolves `.modal-dialog` once, in its constructor, and
      caches it: built against an empty frame it holds a null dialog for the
      life of the instance and throws `Illegal invocation` inside
      `_showElement`. Building it per dialog instead moves the problem rather
      than solving it — replacing the dialog on a validation error tears the old
      instance down while the new one is showing, and the teardown strips the
      backdrop the new one just added, which failed three runs in five. Driving
      the classes directly is a dozen lines with no instance to cache and no
      lifecycle to race; the dialog is shown or hidden by whether the frame has
      children, watched with a MutationObserver, so clearing the frame closes it
      without the server saying so twice. The two dismiss buttons call the
      controller rather than `data-bs-dismiss`.

      Found by running the new file six times rather than once, which is the
      habit the Turbo step started and the second flake it has caught.

      **rails-ujs is gone.** Seventeen links carried `method:` and
      `data-confirm` for it to intercept and carry `data-turbo-method` and
      `data-turbo-confirm` now, with `ButtonComponent` emitting the same for
      the two callers that pass `method:`. Nothing else used the library.

      `payrolls/index` asked for `method: :create`, which is not an HTTP verb.
      rails-ujs put it in a `_method` field, Rack's method override refused a
      verb it does not recognise, and the request stayed the POST the route
      wanted — the button worked by two mistakes cancelling out. It says
      `turbo_method: :post` now.

      Two of those links had no browser coverage, and one was signing out: the
      only thing between the session and a link that had just changed shape was
      a request spec that does not run JavaScript. Both have specs now.

      `layouts/_table.html.erb` and `layouts/_form.html.erb` went with it —
      both opened with a comment calling themselves references to copy from,
      both addressed instance variables no layout sets, and nothing rendered
      either. They were only read because one held a `data-method` link.

      What is still here is jQuery, and its callers are down to two: the
      department-to-designation cascade on the employee form, and select2
- [x] **select2 is replaced rather than kept.** It is a jQuery plugin, so
      leaving it in place would have kept jQuery in `package.json` for one
      control. It attaches to exactly one element in the whole app — the member
      select on the HR leave form — and everything it earns there is a search
      box, a remote lookup on keyup and a `select2:select` event, all of which a
      Stimulus controller does directly. Removing it also drops
      `@import "select2/dist/css/select2"` and the override sitting under it in
      `application.scss`.

      Two costs, neither hidden. The three system specs on that form key off
      `.select2-container`, `.select2-search__field` and
      `.select2-results__option`, so all three are rewritten against the new
      control. And select2 ships the accessibility a combobox needs — roles,
      `aria-expanded`, `aria-activedescendant`, focus handling and keyboard
      navigation — which becomes ours to write rather than ours to inherit.
      That is the actual work in this item; the dropdown itself is an afternoon

      **Taken, and the estimate held.** `ComboboxComponent` renders the WAI-ARIA
      combobox-with-listbox pattern — the input owns `role="combobox"`,
      `aria-expanded` and `aria-controls`, the listbox is a sibling it names,
      focus never leaves the input and the active option is pointed at with
      `aria-activedescendant` instead. `combobox_controller.js` drives it:
      ArrowUp and ArrowDown wrap around the list, Home and End jump to its ends,
      Enter picks, Escape closes, and a `role="status"` live region says how
      many matches arrived. The value submits from a hidden field, so the form
      still posts `applied_leave[member_id]` and the server did not move.

      One thing is better than what it replaced rather than equal to it. The old
      search fired one request per keystroke and raced its own re-render — the
      spec for it had to wait for the DOM append and then type once more to
      re-filter over what landed. The controller debounces and holds an
      `AbortController`, so a keystroke cancels the request before it; the last
      answer is the only one rendered and the workaround is gone from the spec.

      The three specs became eleven, and the new ones are the accessibility:
      picking an employee with the keyboard alone, `aria-activedescendant`
      tracking the active option, exactly one option marked `aria-selected`,
      Escape closing without picking, and editing the text after a pick clearing
      the id — which the old control had no coverage for at all. Each was
      confirmed by breaking the behaviour and watching only that example fail.

      **The department-to-designation cascade went with it**, because it was
      jQuery's other caller and `jquery` cannot leave `package.json` while it
      stands. It is the same controller as the leave-type fill on the HR form —
      `dependent_select_controller.js`, one select refilled from JSON when the
      control it depends on changes — so two near-identical `$.ajax` blocks
      became one controller used twice. The URL carries the literal token
      `VALUE` where the chosen id goes, which lets both views build it from a
      path helper whether the id belongs in the path (`fetch_designations`) or
      in the query string (`get_available_user_leaves`).

      That cascade had no browser coverage whatsoever — it is the third of the
      three `dataType: 'script'` calls, it 404ed silently from the jquery 4 bump
      onward, and nothing in 345 examples touched it. It has four specs now, one
      of which carries a cascade-filled option through to a saved record.

      **`jquery`, `select2`, `show_applied_leaves.js` and `user.js` are gone**,
      and `app/javascript/` is `application.js` plus `controllers/`. The bundle
      is one file where it was two: the `javascript_include_tag` the HR form
      carried went with the second entrypoint. `landing_page_spec.rb` asserted
      `window.jQuery`, `window.$` and `$.fn.select2` as bundle globals; it now
      asserts jQuery is *not* on the window, which is the claim worth holding.
      `$.fn.tooltip` was in that list too and nothing in 114 templates ever
      called a tooltip
- [ ] **Page by page**, layouts first, then the screens behind the sign-in

      **Layouts done.** The four HTML layouts each carried their own copy of
      the same `<head>`, which is how all four came to be missing the same
      three tags. There is one `layouts/_head` now, taking the extra
      stylesheets as a local.

      The tag that mattered is `<meta name="viewport">`, which the application
      has never had. Without it a phone renders at roughly 980px and scales
      down, so every `col-md-*` and `d-flex` in 121 views — the whole reason
      Bootstrap is here — has been doing nothing on mobile since the beginning.
      `<meta charset>` was missing outside the mailer layout, and `<html>`
      carried no `lang`, which is WCAG 3.1.1 and what a screen reader picks its
      pronunciation from.

      Turning the viewport on is not cosmetic: it changes how every narrow
      screen renders, for the first time. Measured rather than assumed, at
      390px. Everything phase 7 has already rebuilt from components fits — the
      HR leave form, the leave queue, the dashboard and settings all report no
      horizontal overflow. What overflows is `users/index`, and the offenders
      are precisely a hand-written `<table class="table table-hover">` that is
      not `TableComponent` and two hand-written `btn btn-primary` links. So the
      remaining page-by-page work now has a measurable acceptance test —
      **fits at 390px** — and passing it is the same work as adopting the
      components.

      Three things in the shared chrome were fixed to get there: the page
      header wraps instead of pushing its actions off the edge, `.page-shell`
      drops to `$space-4` of horizontal padding below 768px, and the auth card
      was `w-50`, which on a phone is half of nothing. It is a `max-width` that
      goes full width when there is no room, and its brand mark takes its
      colour from `$accent` rather than from `bg-primary text-white`.

      Two smaller things. Every page in the application shared one identical
      `<title>Stafflow</title>`; `page_title` puts the page's own name first
      where a view sets `content_for :title`, and seven entry pages set one —
      the rest fall back exactly as before and get theirs as they are rebuilt.
      And the signup layout, which wraps both the marketing page and
      registration, rendered no flash partial at all: `after_sign_out_path_for`
      is devise's default of `root_path`, so signing out landed on a page with
      nowhere to put "Signed out successfully" and looked like it had done
      nothing

      **The employee list is the first screen taken, because it was the
      measured failure.** At 390px the document scrolled sideways to 704px, and
      the offenders were precisely the three things the page hand-wrote rather
      than rendered: a bare `table table-hover` with no responsive wrapper, and
      two `btn btn-primary` links, one of them shoved past the edge by an
      `ms-5`. So passing the measurement and adopting the components were not
      two jobs.

      The heading block and its `col-10`/`col-2` grid are `PageHeaderComponent`.
      The filter row is a flex-wrap strip of `w-auto` controls, replacing three
      `w-25 d-inline` filters that were each claiming a quarter of a row that
      does not exist at 390px. The table is `TableComponent`, and what fixes the
      page is the `.table-responsive` the component already wrapped it in: the
      table still wants 736px and still gets it, inside its own scroll
      container, while the document sits at 390. The empty state is
      `EmptyStateComponent`, matching the queue.

      **The measurement is a spec now rather than a habit.**
      `spec/system/narrow_screen_spec.rb` holds the five pages rebuilt so far
      and grows by one line per page converted. It asks
      `documentElement.scrollWidth > clientWidth`, which is deliberately not the
      same question as "is anything on this page wider than the screen" — a
      table scrolling inside `.table-responsive` is wider, and is correct. It
      was checked the usual way: three separate 900px elements planted on three
      different pages failed exactly those three examples and left the other two
      green, and reverting this page's markup alone failed exactly this page.

      Three classes went because nothing had read them since jQuery left —
      `js-filter-select`, `js-pagination-wrapper`, and the `users_table_rows`
      div the turbo frame had already made redundant.

      One thing found rather than fixed, and it is not counted in the defect
      tally because it is a gap rather than a bug: the three action links in
      each row are icon-only, so a screen reader announced three unlabelled
      links per row. They carry an `aria-label` here, but the same shape sits in
      every list page in the application, so this is a pattern to carry through
      the remaining views rather than something this page finished.

      **Then the other nine index pages, measured as a set rather than one at
      a time.** Five scrolled sideways — departments at 459px, designations at
      498, leaves and events at 410, benefits at 414 — and every one failed on
      the same `col-10`/`col-2` heading block with a `btn btn-primary` in the
      narrow column that the employee list had. That is what made it one change
      rather than five. All ten fit now; the four already passing were not
      touched.

      Only designations was overflowing on its table too. The other four fit at
      the row counts a fixture produces and would not have at real ones, so
      they moved for the same reason rather than waiting to fail — what
      `.table-responsive` buys is that a table's width stops being the
      document's problem at any row count.

      Three tables were malformed and the component fixed them as a
      consequence rather than as an aim: departments and designations put `<th>`
      straight inside `<thead>` with no `<tr>`, and benefits closed a `<tr>` it
      had never opened. Browsers repair all three, which is why nothing had
      noticed in five years.

      `events/_no_events.html.erb` is gone. It was the events empty branch and
      held its own copies of the create and calendar buttons, so those moved up
      into the page header where they render either way. It was also styled in
      `max-wd-md`, `my-10`, `p-12`, `text-indigo-darker` and `text-t2xl` —
      Tailwind class names, in an application that has never had Tailwind,
      inherited from whatever template the 2021 build borrowed the page from.
      Every one of them resolved to nothing.

      One thing found by reading what the list pages render rather than by
      measuring them: `shared/_pagination` opened with
      `stylesheet_link_tag 'pagination'`, which put a `<link>` in the middle of
      the `<body>` on all eight pages that render it. Under turbolinks that was
      merely wrong; under Turbo Drive the body is replaced on every visit, so
      the element was being re-inserted on each navigation. It is a layout
      concern and now sits in the head the layouts pass consolidated, beside
      sidebar and dashboard.

      **Then the eleven pages behind a member.** Four overflowed — the payroll
      list at 449px, the leave allowance list at 442, the benefit allocation
      list at 436 and the available benefits form at 498 — and a fifth,
      `applied_leaves/index`, turned out to have been measured wrong.

      **The false pass is the part worth keeping.** Visited as the account
      owner, `/members/:id/applied_leaves` answers 403:
      `applied_leave_abilities` grants the owner `approve`, `reject` and
      `all_applied_leaves` and never `:read`. An error page fits at 390px, so
      the first measurement reported a page that had never rendered as passing.
      What caught it was the `find('.page-shell')` in the spec's own visit
      helper, which waits for the application layout and fails on anything that
      is not it — measured as HR the page renders, and overflows like the other
      four. This is the 301-examples-green-while-three-pages-500 shape again,
      one layer down: **a measurement that cannot tell "fits" from "never
      rendered" is not a measurement.** The other six pages the probe called
      passing were re-checked with the guard, and all six genuinely render and
      genuinely fit.

      Three more malformed tables went the way of the last three. payrolls and
      users_benefits put `<th>` straight inside `<thead>` with no `<tr>`, and
      users_benefits then closed a `<tr>` it had never opened; available
      benefits opened its `<table>` outside the `present?` branch and closed it
      inside, so the empty case emitted a table that was never closed. That
      branch now wraps the whole form rather than splitting a tag across it.

      Two smaller things. `available_benefits` dropped a `custom-control
      custom-checkbox` wrapper — Bootstrap 4 class names, on an application
      that has been on 5 since the tokens step, so they styled nothing and the
      checkbox looks exactly as it did. And `applied_leave.links.edit`, `.show`
      and `.delete` were dead keys rendered by nothing; two are repurposed as
      the accessible names for the row's links. Adding a second `delete` beside
      the existing one was caught by the locale spec above, which is the first
      thing it has caught.

      **Then the seven resource forms** — department, designation, leave,
      benefit, event, applied leave and benefit allocation. These fitted at
      390px already, so this is the first step of the page-by-page work with no
      measured failure behind it: the argument is the component layer rather
      than the acceptance test.

      `.form-card` is a max-width rather than a column count, which is the one
      design decision in it. Every form was bounded by `col-md-6` or `w-50` —
      a fraction of the viewport, not a measure — so the same form was half of
      nothing on a phone and 900px of input on a desk monitor.

      **The specs are the point of this step, not the markup.** Moving to
      `FormFieldComponent` changes the markup around every control and replaces
      an `<input type=submit>` with a `<button>`. `forms_spec` covers label
      association and `narrow_screen_spec` covers width, and **neither can see
      whether the value still reaches the database.** The department form was
      already carried end to end by `turbo_spec`; the other six were not, and
      `spec/system/resource_forms_spec.rb` carries each one from a filled field
      to a saved record. Each was confirmed by disabling the control it depends
      on and watching only that example fail.

      Writing them turned up nothing wrong with the application and two things
      wrong with the first draft of the specs, both worth naming because both
      read as defects at first. `designation.department` evaluated outside the
      `as_tenant` block comes back nil, which looks exactly like the form
      having dropped the value — the trap this file already records, met from
      the other direction. And `fill_in` with a String into an
      `<input type="date">` can leave the control invalid, so `required` blocks
      the submit in the browser and the page sits there with no request made
      and no error shown, which is indistinguishable from a form that does not
      work. Passing a `Date` is what makes it submit. The event form was never
      broken, and the copy on `develop` failed the same probe identically —
      which is how that was settled rather than assumed.

      A third false reading came from the width probe rather than a spec:
      `users_benefits#edit` is `load_and_authorize_resource ... find_by:
      :sequence_num`, so a URL built from `id` 404s. The probe had built one by
      hand; the spec beside it used the path helper and was fine. Twice now the
      throwaway probe has been wrong where the spec was right, which is the
      argument for the `.page-shell` guard being in the spec's helper rather
      than in the probe.

      Two markup faults fixed on the way: `users_benefits/_form` opened a `row`
      and a `col-md-4` and closed neither, and `.event-date` / `.event-time`
      carried `padding-right` and `padding-left` from when those halves were a
      flex row — as a Bootstrap row the gutter already spaces them, and at
      390px, where the columns stack, that padding indented the time field out
      of line with the date above it. Only a screenshot at both widths would
      have shown that, which is what the phase says appearance review is for.

      **`ModalComponent` closes the component set.** It is the one the plan
      named and nothing had built: the leave allocation dialog hand-wrote
      `modal-dialog`, `modal-content`, `modal-header`, `modal-body` and
      `modal-footer`, its own close button, and `form.label` calls.

      Bootstrap's Modal is still not used, for the reason recorded when the
      dialog was first built, and `modal_controller.js` is unchanged — the
      component renders what that controller shows.

      **The form wraps the component rather than sitting in a slot**, and that
      is the one design decision in it. The form has to span the body and the
      footer, because the submit sits beside the dismiss and both belong inside
      the same form element as the fields; slots are assigned in the component's
      own block, so a form opened inside that block cannot contain them.
      Wrapping puts `<form>` between `.modal` and `.modal-dialog`, which
      Bootstrap's descendant selectors read through unchanged — confirmed by
      screenshot rather than assumed. The slot is `messages` rather than
      `flash`, which would shadow the Rails helper of that name inside the
      template.

      The dialog names itself now: the layout's modal carries `role="dialog"`,
      `aria-modal="true"` and `aria-labelledby`, pointed at the component's
      title, so a screen reader announces it by its heading instead of reading
      an unnamed group. Removing the id from the title fails that example and
      only that one.

      `_user_leaves_table.html.erb` went with it — a copy of the rows in
      `_user_leaves_list`, rendered by nothing since the frames work, still
      carrying the pre-component icon links.

      **Then the detail views** — users/edit, users/edit_password, users/new,
      users/show, leaves/show, events/show, user_leaves/show, user_leaves/new,
      notifications/index, settings/_form and the HR leave form's submit.

      **A correction to this file, left standing beside what it corrects.** The
      `FormField` item above says the eleven views not yet converted "had the
      association fixed in place rather than waiting for the migration". Two of
      them were not. `users/edit_password` had all three of its labels pointing
      at nothing and `users/edit` had eight of ten, still calling the
      one-argument `form.label` — `for="user_Current Password"` against an input
      with id `user_current_password`. Measured before the change rather than
      inferred: eleven orphaned labels, and zero after.

      What made the claim survive is worth more than the fix. `forms_spec`
      covered the employee, settings, benefit, department and designation forms
      and the two signed-out ones — **which is exactly the set that had been
      fixed.** The suite agreed with the record rather than with the
      application, and a check that only looks where the work was done cannot
      tell you the work was incomplete. Both pages are named in it now, and
      reverting either fails its own example.

      `.card-body p` in `dashboard.scss` was a dashboard stat style wearing a
      global selector — centred, 4xl and bold on every paragraph in every card
      in the application. It is `.stat-figure` now, on the three dashboard
      numbers that wanted it. **Not counted as a defect**, and the distinction
      was checked rather than assumed: `leaves/show` on develop already puts a
      `<p>` inside a `.card-body`, so the rule was reaching it there too, and
      inside a `text-center` card the result was plausibly intended. What is
      wrong is the selector, not the appearance it happened to produce.

      Two more markup faults of the shape this phase keeps finding:
      `user_leaves/new` opened its `<table>` outside the `present?` branch and
      closed it inside, with the submit button sitting between `<tbody>` and
      `</tbody>`; and `users/show` wrapped the profile image in
      `file btn btn-lg btn-primary` and then overrode the border, radius,
      background and font-size in `.file`, so the only thing the button classes
      contributed was a box. `.file` declares that box itself now.

      Three "Back" links pointed at `:back`, which reads the Referer. They point
      at their index instead, so where the button goes no longer depends on how
      the page was reached.

      **Then devise and the chrome, which is where the item ends.** The five
      devise forms with a label-beside-field grid, the signup submit, the navbar
      search, the search result link, and the footer.

      The devise forms stop putting their labels in a `col-3`. At 390px three of
      twelve columns is about 65px, and "Password" already filled it edge to
      edge on the sign-in page. Stacked `FormField` labels now, like every other
      form here. None of the five was overflowing — measured first — so the
      screenshots are the argument rather than the acceptance test.

      **`registrations/new` keeps its floating labels, and that is a decision
      left open rather than made.** `FormField` renders label-then-control and a
      floating label needs the reverse, so converting it means either a floating
      mode on the component or a design change to the front door. The
      application therefore has two label patterns — stacked everywhere,
      floating on signup — which by this phase's own "a second palette is a
      second system" argument wants settling one way or the other.

      `layouts/_footer.html.erb` is rendered by nothing. The landing page has
      its own footer inline, and this one held six `href="#"` social links and a
      hard-coded "© 2021 Copyright: Company". That is the fourth dead layout
      partial found this way, after `_navbar`, `_table` and `_form`, and the
      pattern is worth naming: **a partial nothing renders is invisible to every
      check in this repository, including the ones added this phase.**

      Two labels were rendering a Ruby symbol rather than a translation.
      `link_to :details` on the search results and `submit_tag :search` in the
      navbar both put the symbol's name on the button — "details" and "search",
      lower case, in English whatever the locale, the second on every signed-in
      page.

      **`ButtonComponent` gained a `dark` variant, and the contrast spec is the
      reason.** The navbar search moved to `:secondary` first, which is
      `btn-outline-secondary`, and `colour_contrast_spec` failed it at 1.07:1
      against the brand blue it sits on. `btn-dark` was load-bearing rather than
      arbitrary, and that spec is the only thing in the suite that could have
      said so.

      What is left hand-writing `btn btn-*` is two views, both deliberately:
      `simple_calendar/_month_calendar`, which is a gem template override whose
      markup is simple_calendar's contract rather than ours, and
      `dashboard/_form` — a `<form>` with no action, two `href="#"` icons and a
      submit that does nothing, above a hard-coded feed. Converting either would
      dress up something that is not wired to anything; they want a decision,
      not a component.

      **`dashboard/_form` got its decision: removed.** The first screen after
      signing in showed a composer and four announcements, none of them real.
      `_announcement_card` opened with `<!-- dummy data used !-->`, was rendered
      four times, and carried a hard-coded name, designation and quote from
      `en.yml` — one of the 2021 contributors, posting the same line four times,
      each stamped "less than a minute ago" because the timestamp was
      `DateTime.now`. The composer above it was a `<form>` with no action, two
      `href="#"` icons and a submit wired to nothing.

      **This is the category phase 0 cleared, and it survived that pass because
      phase 0 was reading the landing page and this sits behind the sign-in.**
      Worth recording as a limit on how that phase was done rather than as a
      failure of it: "read the pages a visitor sees" finds branded copy on the
      front door and nothing at all on the dashboard.

      Removed rather than converted, and rather than built. Restyling dresses up
      a control that does nothing; building it is a phase 5 feature, not part of
      rebuilding an interface. What is left is what was already true — three
      counts and two charts, all real queries — as a row of three cards above
      the graphs, which is what the space is for once the feed is gone.

- [ ] **font-awesome 5.15 → 6, or out.** `app/views/shared/svgs` already exists,
      so inline SVG is a live option and drops a gem

### Two things to be honest about going in

The 72 system specs are what makes this safe, and they are also going to get in
the way. They assert behaviour rather than appearance, so a re-skin cannot
silently break the app — but several key off framework classes
(`.select2-container`, `.card`, `#read-button[disabled]`) and will need
rewriting as components land. The right fix is for components to expose stable
hooks so specs stop coupling to Bootstrap's vocabulary; doing that as each
component arrives is part of the work, not a tax on it.

And nothing in the behaviour suite covers appearance. This was demonstrated
rather than argued: appending one plausible token mistake to `application.scss`
— body text landing on the body background — rendered the payslip page
completely blank, and all 21 system specs passed against it, including the
three assertions on the currency figures a human could no longer see.

So appearance is reviewed by eye at every step, and the screenshots are read
rather than glanced at. Pixel comparison was considered and left out: on a
design that changes every PR it produces diffs that are almost all intended,
and a check people learn to click through is worse than no check.

The one part of appearance that *is* measurable is colour, and that is
enforced. `spec/system/colour_contrast_spec.rb` reads what the browser
computed — walking up for the painted background, flattening any alpha — and
fails anything under WCAG AA. It exists because the first token pass shipped a
hero subtitle at 2.81:1 against a 3:1 floor, and nothing else would have
caught it.

**Done when:** no view hand-writes `btn btn-*`, tokens are the only source of a
colour, the component previews are reachable, and jQuery and turbolinks are
both out of `package.json`.

---

## Defect backlog

Line numbers current as of 29 Aug 2026.

### Open

| Location | Problem |
| --- | --- |
| `config/environments/production.rb` | `config.action_mailer.default_url_options` is set in `development.rb` and nowhere else. Devise is `:confirmable`, so creating a user mails confirmation instructions, and that template builds a `confirmation_url` — with no host configured it raises `ArgumentError: Missing host to link to!`. **Creating an employee 500s in production.** It has never been covered: nothing in the suite POSTed `/members` until the cascade spec in the select2 item did, and it raised there for the same reason. Test now sets `host: 'localhost'`; production is left open deliberately, because the value is the deployed apex domain that the mailer appends a tenant subdomain to, and that is a phase 4 decision rather than a guess to make here |

`payroll.rb` closed during the Rails 6.1 upgrade rather than on its own: the
deprecation that forced the transaction block to be restructured took the
block-local `rescue` with it.

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
| `app/views/shared/_sidebar.html.erb` | The Logout link was `destroy_user_session_url(subdomain: nil)`, sending sign-out to the apex host. The session cookie is host-only, so that request never carried it: devise found nobody signed in, said so, and left the session running. Signing out did not sign you out |
| `app/controllers/search_controller.rb` | No `authenticate_user!` and no `load_and_authorize_resource` — the only controller with neither. An anonymous request ran a real Elasticsearch query across every tenant's records, then 500d on the layout where its siblings answer 403 |
| `app/models/event.rb` | `rescue Type::Error` names a class that does not exist. Ruby evaluates rescue clauses in order and only when something is raised, so this one raised `NameError` before the working `Date::Error` clause beneath it could be reached — every unparseable event date 500d, not just a missing one |
| `app/models/event.rb` | No `belongs_to :company`, alone among tenant-owned models, so `Event.new(company:)` raised `UnknownAttributeError` and the factory set the id by hand |
| `app/models/event.rb` | `validate_past_event_date` compared `nil < DateTime.now` when no start was given, the same shape as the applied-leave validators fixed in phase 2. `starts_at` now has a presence validation to report instead |
| `app/controllers/events_controller.rb` | `set_event` defined twice; the second silently replaced the first, which was dead. `.rubocop_todo.yml` excluded `Lint/DuplicateMethods` for the file rather than removing the duplicate |
| `app/controllers/applied_leaves_controller.rb:9` | The controller-wide breadcrumb points at `member_applied_leaves_path`, which needs a member id. `new_applied_leave_by_hr` is reached from the company-wide list and carries none, so the layout raised and the page 500d for HR, the only role that can reach it |
| `app/controllers/search_controller.rb`, `app/views/search/search_data.html.erb:1` | The Elasticsearch query was not partitioned by company, so `@results.total_count` counted every tenant's hits. The rows were right — the default scope drops other tenants when the ids are loaded — but the number above them was not, and the empty-state branch tested it: a name only another company had left the view on the results branch with nothing to render. Searchkick also logged the ids it could not load, naming other tenants' records |

Found after phase 3 shipped, by opening the page rather than by any check the
repository runs:

| Location | Problem |
| --- | --- |
| `app/javascript/channels/index.js` | `require.context`, a Webpack API with no esbuild equivalent. The esbuild migration added `require("./channels")` to `application.js` and carried this file over unconverted. esbuild resolves `require.context` to a property on its own require shim rather than rejecting it, so the build stayed green and the bundle threw `Zh.context is not a function` on line 4 — taking every line below it with it, on every page. No jQuery global, no Bootstrap, no select2, no Chartkick, no tooltip or pagination handlers. The landing page rendered as an empty blue block because AOS never initialised and its elements hold `opacity: 0`. Nothing here has any channels: no `*_channel.js` file existed, nothing imported `consumer.js`, and the glob matched nothing even under Webpack |
| `app/models/applied_leave.rb` | No validation on `leave_duration_type`, which is permitted straight from params, so any integer reached the column. The views render `t("applied_leave.links.#{leave_duration_name}")`, and `leave_duration_name` looks the value up in `LEAVE_DURATION.invert` — an unlisted value gives `nil`, the key interpolates to the bare `applied_leave.links.`, and I18n answers a bare key with the whole subtree. The HR review queue printed the entire `links` hash into the leave-duration cell, for every user of that tenant, from one crafted request by any employee. Found by taking a screenshot of the page for the phase 6 capture |

Found by the first run of the first system spec, both fixed alongside it:

| Location | Problem |
| --- | --- |
| `app/javascript/application.js:9` | `require("select2")` never registered anything. Under CommonJS select2's UMD wrapper exports a factory — `module.exports = function (root, jQuery)` — instead of calling it, so `$.fn.select2` was never defined and `show_applied_leaves.js` threw `$(...).select2 is not a function` on every page that loads it. That kills the rest of its `$(document).ready`, which is where the HR leave queue's mass approve and reject buttons and its filter are wired. The comment above the line asserted the opposite, that select2 registers itself on the jQuery above, and was the reason nobody looked. `require("select2")()` is the fix |
| `app/views/applied_leaves/_applied_leaves_list.html.erb:21,24`, `app/views/applied_leaves/_applied_leaves_index.html.erb:6` | Both interpolated cells looked their keys up under `applied_leave.links`, which holds action labels. The states and durations are under `applied_leave.labels`. A key the view interpolates its way to and misses does not raise: `translate` renders `<span class="translation_missing">` around the humanised last segment, so `full_day` printed as "Full Day" and `pending` as "Pending" — close enough to the real labels to survive every review and every screenshot. This also moves the subtree the defect above it returns from `links` to `labels`; the validation added there still guards it |
| `app/javascript/show_applied_leaves.js:83,102`, `app/javascript/user.js:50` | Three `$.ajax` calls asked for `dataType: 'script'` from endpoints answering `format.json`, then ran `JSON.parse` over the result. jQuery 3 sent `*/*` alongside `text/javascript` in the Accept header, Rails fell back to JSON on it, and the text parsed cleanly — so it worked by negotiation accident. jQuery 4 dropped the wildcard, leaving Rails nothing to match, and all three 404. Nothing throws: the employee search, the leave-type cascade on the HR leave form and the department-to-designation cascade on the employee form each just leave a select empty, which is why no console error and no green suite would have found it. Found by specs written for the jquery 4 bump before taking it |

Found while consolidating the four layouts into one `<head>`:

| Location | Problem |
| --- | --- |
| `app/views/layouts/application.html.erb`, `landing.html.erb`, `signup.html.erb`, `component_preview.html.erb` | No `<meta name="viewport">` in any layout, so every mobile browser rendered the application at roughly 980px and scaled it down. Bootstrap's grid is the layout system across all 121 views and none of it has ever reflowed on a phone. Also no `<meta charset>` outside the mailer layout, and no `lang` on `<html>` — WCAG 3.1.1, and what a screen reader takes its pronunciation rules from. All three were missing from all four layouts because the `<head>` was copy-pasted four times, which is the actual defect |
| `app/views/layouts/signup.html.erb` | The layout rendered no flash partial. It wraps the marketing page, which is `root_path`, which is what devise's default `after_sign_out_path_for` returns — so "Signed out successfully" was written to a flash that the page it landed on had nowhere to render. Signing out worked and looked like it had not |

Found while replacing select2, in the endpoint the new control reads:

| Location | Problem |
| --- | --- |
| `app/controllers/applied_leaves_controller.rb:181` | `render json: @users` over the relation sent every column Devise does not blacklist for serialization — base salary, date of birth, gender, home city, first and last name, and the department, designation and role ids — for every employee whose email matched the query. The control has only ever read `id` and `email` off each record, and the select2 handler that preceded it read the same two, so nothing ever wanted the rest. `.select(:id, :email)` is the fix, with a request spec asserting the key set rather than the values. `email LIKE?` in the same line also lost its missing space |

Found while building the component that made it impossible:

| Location | Problem |
| --- | --- |
| 34 labels across 12 views, including all six devise forms | `form.label t('forms.labels.email')` passes the translated string where Rails expects the attribute name, so the label was rendered as `for="user_Email"` against an input with id `user_email`. Nothing looks wrong — the text is correct — but the label is associated with no field: clicking it focuses nothing and a screen reader announces the input unlabelled. Two views moved to `FormFieldComponent`, which takes the attribute and the text separately; the other eleven had the association fixed where they stand |

Found while moving the list pages onto Turbo Frames, all four on pages the
suite rendered nowhere — 301 examples passed while three of them answered 500:

| Location | Problem |
| --- | --- |
| `app/views/events/index.html.erb` | The events table, its heading, its Create button and every row's edit and delete link were nested inside the `link_to` to the calendar. An anchor cannot contain another, so the parser split it into six anchors and the page rendered as four empty pill outlines with the table squeezed into a column beside them. The `.js.erb` meant to refresh it targeted `#events_table` while the div carried `class="events_table"`, so it could not have repaired the page either |
| `app/views/events/index.html.erb` | `render partial: 'no_events.html.erb'` names a partial `no_events.html.erb`, not the file of that name, so Rails looked for `_no_events.html.erb.html.erb` and raised. The events page 500d for any company with no events, which is the first thing a new tenant sees on it |
| `app/views/leaves/index.html.erb` | The controller paginates to `PAGE_SIZE`, which is 5, and the view rendered no pagination control at all, so a company's sixth leave type could not be reached from the page. `_leaves_list.html.erb` does carry one, but was rendered by nothing except the dead `index.js.erb` beside it and had drifted to an older style — a dark header and text buttons against the themed icons the index uses |
| `app/javascript/application.js`, `app/views/leaves/index.js.erb`, `app/views/events/index.js.erb` | Three pieces of machinery for a thing that could not happen. `events#index` answers `format.html` only, so its `.js.erb` was a template for a request the action rejects; both `.js.erb` files targeted ids no page has ever contained; and the `.leave-pagination-wrapper` handler was bound on every page load against a class no view carries |
| `app/views/applied_leaves/approve_leaves.js.erb` | The mass approve and reject confirmation was written into `$("#flash_message")`, and no element with that id exists anywhere in the application. The message reports how many of the selected requests actually changed state — the number that matters when some of them cannot — and it went into an empty selection on every bulk action the application has ever processed |
| `app/javascript/notifications.js` | Marking notifications as read gave no feedback. The button fired an `$.ajax` POST with no success handler, so the rows were marked read in the database and stayed on screen until something else reloaded the page — the click looked like it had done nothing |

Found by navigating away from a page and pressing back, which is the first
thing the Turbo swap made possible to get wrong:

| Location | Problem |
| --- | --- |
| `app/javascript/application.js` | Turbo snapshots the page it is leaving and restores that snapshot on a back navigation, and select2 builds its control as a sibling of the select it wraps. So the snapshot carried the control, the body bundle re-ran on restore and built a second one, and the HR leave form came back with two dropdowns stacked over one select. turbolinks did not do this — the same probe on `develop` reports one container before and after — so it arrived with Turbo rather than being something Turbo exposed. Torn down on `turbo:before-cache`, from the bundle the layout loads in `<head>` rather than from the body bundle beside the `.select2()` call, because body bundles are re-executed on every visit and a listener added there accumulates one copy per navigation |

Found by measuring what the column stores rather than by reading the schema:

| Location | Problem |
| --- | --- |
| Eleven columns across `applied_benefits`, `benefits`, `leaves`, `payrolls`, `settings`, `user_leaves`, `users` and `users_benefits` | Money and leave balances declared `t.float`, which on MySQL is `FLOAT(24)` — single precision, about seven significant decimal digits, not the `double` the name suggests. Salaries need more. `1234567.89` read back as `1234570.0` and `100000.10` as `100000.0`, so a payroll generated from a base of `100000.10` at a 10% rate came out `$87.74` short on the gross, with the cents gone from every derived figure and from the rendered payslip. Now `decimal`: `(15, 2)` for money, `(6, 3)` for the tax rate, `(6, 2)` for leave counts. The leave columns were not demonstrably broken at their magnitudes and moved for consistency. What the float already rounded away stays rounded away — the migration fixes what is written from here on |

Found by parsing the locale files rather than by reading them, and recorded
here as the exception that proves the tally rather than as an entry in it:

| Location | Problem |
| --- | --- |
| `config/locales/devise.en.yml:101,108,151` | `forms.labels.role`, `forms.labels.department` and `headings.change_password` were each defined twice. **Not counted as defects, because all three pairs hold identical values** — Psych keeps the last key it reads, so nothing was dropped and no screen was wrong, which is exactly what separates these from the four phase 0 closed and the `applied_leave.headings.leave_type` phase 2 closed, where the values differed and the wrong one won. What made them worth removing is that the trap is set either way: the copy a reader finds first is the one not in effect, so editing it changes nothing, silently. `spec/config/locale_files_spec.rb` now walks the Psych AST of every file in `config/locales` and fails on any key defined twice at any depth — it has to read the files as files, because by the time I18n has loaded them the duplicate is already gone |

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

**Reversed on the demo, 31 Aug 2026.** "The demo comes before new features"
was written against phase 5 — a fifth module nobody can reach — and phase 7 is
not that. It is the interface the demo would be showing. Deploying first would
have put a URL in the README pointing at the one part of this project nobody
has touched since 2021, and every argument above for shipping early assumes
what ships is worth looking at.

The cost is real and worth naming: the deploy work stays unvalidated for
another two or three weeks, and phase 4 carries the unknowns — wildcard TLS,
managed Elasticsearch, searchkick reindexing per tenant — that are easier to
find early. Phase 7 runs first anyway.

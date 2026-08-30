# Roadmap

A multi-tenant HR system in Rails, built by four engineers in 2021 and now
being brought back to a state worth showing. The architecture was always the
strong part. This is the sequence for making the rest match it.

Phases are ordered by what a reviewer notices first, not by what is most
interesting to build. Phases 1 and 2 are the ones that change how the repo
reads; everything after is depth.

## Where it stands

The app runs from a clean clone in three commands, on a current stack, with a
suite in front of it and the known defects cleared. What it still lacks is
somewhere to run.

| | |
| --- | --- |
| Commands to run from a clean clone | 3 |
| Tests | 233 examples, 0 pending |
| CI workflows | RSpec, RuboCop and Brakeman on push and PR |
| Lines in `app/` | 4,939 across 22 controllers, 30 models, 121 views |
| Known defects | 23 found, 23 fixed, 0 open |

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
      gem instead, and the five front-end updates are held for verification
      that can see them. The twelfth is Rails 8.1, which is a phase and not
      a bump.

      `jbuilder`, `capybara`, `selenium-webdriver` and `webdrivers` had no
      reference anywhere in `app`, `lib`, `config`, `spec`, `bin` or `db`,
      and no `.jbuilder` template exists. The system-test trio arrived with
      `rails new` in 2021 and was never used; `webdrivers` has had no
      upstream commit since January 2024 and pinned `selenium-webdriver` below
      4.0. Removing them takes ten gems out of the lockfile, four direct and
      six pulled in behind them. If system specs are written, they will want
      a current Capybara and a driver strategy chosen then, not a 2019
      Selenium held in place by a Gemfile.
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

Estimated 3–5 days.

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

None.

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

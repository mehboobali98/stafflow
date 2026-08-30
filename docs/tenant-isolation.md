# Tenant isolation, and the hook that nearly worked

Every tenant-owned table in this application carries a `company_id`, and every
query against them has to be narrowed to the current tenant. Leaving that to
individual queries is not an option: one forgotten `where` in one controller
action shows one company another company's payroll.

So the scoping is automatic. What follows is how it is done, why the first
version of it was wrong in three ways, and why none of those ways showed up as
a failing test.

## The ordering problem

The obvious place to install a default scope on every model is
`ApplicationRecord.inherited`, which Ruby calls the moment it sees

```ruby
class Payroll < ApplicationRecord
```

A few models must not be scoped — `Company` above all, since resolving the
tenant means querying it before a tenant exists. They opt out by calling a
class method in their body:

```ruby
class Company < ApplicationRecord
  set_not_multitenant
```

And there is the problem. `inherited` fires when Ruby sees the `class` line,
**before the body runs**. At the moment you would install the scope,
`set_not_multitenant` has not been called yet. You cannot know whether this
model wants scoping, because the model has not said so yet.

## The first answer

Wait for the body to finish, then decide:

```ruby
def self.inherited(subclass)
  super

  return if ENV['skip_default_scope'].present?
  subclass.instance_eval do
    def set_not_multitenant
      @not_multitenant = true
    end

    def multitenant?
      @not_multitenant.nil?
    end
  end

  trace = TracePoint.new(:end) do |trace_point|
    if trace_point.self == subclass && trace_point.self.multitenant?
      trace.disable
      subclass.instance_eval { default_scope { where(company_id: Company.current_company_id) } }
    end
  end
  trace.enable
end
```

`TracePoint` with the `:end` event fires whenever any class or module body
finishes. The block waits for the one belonging to this subclass, checks
`multitenant?` — which by then has an answer — and installs the scope.

This addresses the ordering problem directly and it works for the case anyone
would test. It was reviewed, read closely, and pronounced sound.

## Three faults

None of them changes a query in any case the suite exercises. That is why the
suite stayed green, and it is the reason they are worth writing down.

### 1. Every opted-out model leaks a process-wide hook

`trace.disable` sits **inside** the branch that installs the scope. A model
that opts out never enters that branch, so it never disables its own
`TracePoint` — which stays enabled, globally, for the life of the process.

`Company` is such a model. So the application leaked one enabled process-wide
`:end` hook per boot, and one more on every code reload: two after boot, rising
to seven across five reloads. Every `end` of every class and module body
anywhere in the process — application, gems, the framework — then ran that
block to ask whether it belonged to `Company`.

Measured rather than assumed, this turned out not to be a speed problem: 2,000
class bodies took 0.014s with no hooks enabled and 0.015s with one. But the
count only ever grows, and a hook that outlives its purpose is a hook nobody
is reasoning about any more.

### 2. A safety valve that could never have worked

```ruby
return if ENV['skip_default_scope'].present?
```

That `return` happens **before** `set_not_multitenant` and `multitenant?` are
defined on the subclass. So setting the variable did not skip the default
scope. It stopped boot, on `Company`'s body, at the `set_not_multitenant` call
that now referred to a method that had never been defined.

It is referenced nowhere else in the application. It cannot ever have worked.

It was removed rather than repaired. `unscoped` already covers the legitimate
need, and a process-wide environment variable that silently turns off tenant
isolation is not a thing this application should own.

### 3. The one that failed open

`:end` is emitted by a `class ... end` body. It is not emitted by

```ruby
Class.new(ApplicationRecord)
```

An anonymous subclass built that way has no body and fires no `:end` event, so
the hook never ran and **no default scope was ever installed**. Every query on
such a model would have run across every tenant.

Nothing in this application is defined that way, so nothing was actually
leaking. But note the direction. The first two faults cost memory and a broken
flag. This one silently removes tenant isolation and looks exactly like
success: no error, no warning, results returned, rows rendered.

A mechanism whose job is isolation should fail closed. This one had a path
where it failed open.

## The replacement

```ruby
def self.inherited(subclass)
  super

  subclass.instance_eval do
    def set_not_multitenant
      @not_multitenant = true
    end

    def multitenant?
      @not_multitenant.nil?
    end

    default_scope { multitenant? ? where(company_id: Company.current_company_id) : all }
  end
end
```

`default_scope` takes a block, and Active Record evaluates that block **per
query**, not when the class is defined. So the ordering problem dissolves: the
scope is installed immediately, at a point where the answer is still unknown,
but the question is not asked until the first query — by which time the class
body has long since run and `multitenant?` has its answer.

The hook was never solving a problem that needed a hook. It was compensating
for asking the question too early.

No `TracePoint`. No process-wide state. No event that some ways of defining a
class happen not to emit. And the anonymous-subclass case now behaves like
every other: `Class.new(ApplicationRecord)` gets the scope, because it gets it
from `inherited`, which anonymous subclasses do trigger.

## Failing closed

With no tenant set, `Company.current_company_id` is `nil`, and

```ruby
where(company_id: nil)
```

compiles to `company_id IS NULL`. No tenant-owned row has a null `company_id`,
so an unset tenant matches nothing. A request that somehow reaches a model
query without a resolved tenant returns an empty result, not every tenant's
rows.

The `around_action` that sets the tenant clears it in an `ensure` block, so a
thread that raises mid-request cannot carry one tenant's context into the next
request it serves.

## What was checked

The rewrite was verified by reading the generated SQL for the scoped,
no-tenant, opted-out and anonymous cases, rather than by the suite going green
— a green suite is exactly what the original had.

```
anonymous subclass default_scopes: 1
anonymous scoped SQL:  SELECT `payrolls`.* FROM `payrolls` WHERE `payrolls`.`company_id` = 5
Payroll scoped SQL:    SELECT `payrolls`.* FROM `payrolls` WHERE `payrolls`.`company_id` = 5
Payroll unset SQL:     SELECT `payrolls`.* FROM `payrolls` WHERE `payrolls`.`company_id` IS NULL
Company default_scopes: 1
Company SQL:           SELECT `companies`.* FROM `companies`
Company.new attrs:     {}
```

The first two lines are the fault that failed open, closed: an anonymous
subclass now produces exactly the SQL a named model does. The third is the
fail-closed behaviour. The last three are the one difference worth recording —
`Company` now carries a default scope that evaluates to `all` where it carried
none, so `Company.default_scopes` reads 1 rather than 0. Its SQL is unchanged
and `Company.new` still sets no attributes, but the count is visible to
anything that inspects it.

## What this cost, and what it is worth

The hook was read carefully by someone looking for exactly this kind of
problem, and passed. All three faults live in paths that reading tends to skip:
what happens when a model *opts out*, what happens when an environment variable
nobody sets is set, and what happens to a class defined by a route the code
does not mention.

The suite could not have caught them either. Nothing here opts out except
`Company`, nothing sets the variable, and nothing builds a model anonymously.
Every fault was in behaviour that was never exercised — and one of them was a
tenant isolation hole.

The lesson is not "avoid `TracePoint`". It is that a mechanism protecting a
boundary should be judged on its failure modes rather than its success path,
and that "the tests pass and it reads correctly" establishes less about such a
mechanism than it feels like it does.

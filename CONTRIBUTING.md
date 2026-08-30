# Contributing

## Branching model

This project follows git-flow.

```
main                       production. Always deployable. Never committed to directly.
└── develop                integration branch. Default target for day-to-day work.
    ├── feature/<name>     new work, branched from develop, merged back into develop
    └── hotfix/<name>      urgent fixes, branched from develop, merged back into develop
```

`main` only ever moves by merging `develop` into it at release time.

### Starting work

Always branch from an up-to-date `develop`:

```sh
git checkout develop
git pull origin develop
git checkout -b feature/leave-carryover      # or hotfix/payroll-email-subject
```

### Naming

Use a short, hyphenated description of the change:

| Prefix | Use for | Example |
| --- | --- | --- |
| `feature/` | new functionality or refactors | `feature/leave-carryover` |
| `hotfix/`  | bug fixes | `hotfix/payroll-email-subject` |
| `chore/`   | tooling, docs, dependencies | `chore/rubocop-config` |

Avoid vague names such as `feature/changings` or `feature/ui_changings`.

### Merging

Open a pull request into `develop`. Merge with a merge commit (`--no-ff`) so the
feature's commits stay grouped and the branch point is visible in history.
Branches are kept after merging rather than deleted, so the history a
released commit came through stays reachable by name.

Releasing is a pull request from `develop` into `main`.

### Keeping a branch current

Rebase rather than merge `develop` into your branch, so history stays linear:

```sh
git fetch origin
git rebase origin/develop
```

## Commit messages

Write a short imperative subject line, then explain *why* in the body if the
change is not self-evident. Reference the behaviour that changes, not the files
touched — the diff already says which files.

## Before opening a pull request

- The app boots and the affected pages render
- No new `translation missing` keys (every user-facing string goes through `t()`)
- No secrets, credentials or real personal data in the diff

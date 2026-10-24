# homebrew-frodo-cli: instructions for coding agents

The Homebrew tap that installs [frodo-cli](https://github.com/rockcarver/frodo-cli). It is one of the Frodo repositories: [frodo-cli](https://github.com/rockcarver/frodo-cli) and [frodo-lib](https://github.com/rockcarver/frodo-lib). There is no build: two Ruby formulas and one test.

## Formulas

- `Formula/frodo-cli.rb` is the stable formula. Today it is still the 4.x source build; the first stable release after the pipeline change replaces it with the prebuilt-binary form.
- `Formula/frodo-cli-next.rb` is the prerelease channel. It downloads the release's prebuilt per-platform zips (`on_macos` / `on_linux` blocks with pinned sha256).

## Rules

- **Do not hand-edit the formulas.** frodo-cli's release pipeline (the `homebrew-formula-update` job, which runs `tools/update-homebrew-formula.mjs` in frodo-cli) regenerates them and pushes straight to `main` as `rockcarver-pipeline`. A manual edit is overwritten by the next release. Change the generator in frodo-cli instead.
- **Run `ruby test/version_checks_test.rb`** after any change that touches a formula's `frodo -v` check. It needs no Homebrew.
- **Keep the pipeline's push conflict-free**: it commits only `Formula/*.rb`, so do not add other generated files there, and keep any workflow path-filtered, scheduled or started by hand, so a formula push never starts one.
- **Never commit credentials, keys or tokens.**
- **Do not edit the Repo Concierge's files**: `.github/workflows/*.lock.yml` and the `.md` workflow sources beside them, `check-deployment.yml`, `concierge-updater.yml`, `dependency-watch.yml`, `janitor.yml`, `plan-approval-resume.yml`, `pr-ready-signal.yml`, `reporter-notify.yml`, the scripts of the same names (`check-deployment.mjs`, `concierge-updater.mjs`, `dependency-watch.mjs`, `janitor.mjs`, `plan-approval-resume.mjs`, `pr-ready-signal.mjs`, `reporter-notify.mjs`) in `.github/scripts/`, `.github/aw/`, `.gitattributes` and the pin in `.github/concierge.yml`. An updater overwrites them. `decision-records.yml`, `core-records-drift.yml`, `validate-decision-records.*` and `check-core-records-drift.*` in `.github/scripts/`, and `.github/agentic-workflows/scope.md` belong to this repository. None of the Concierge's workflows starts on a push of `Formula/*.rb`: they run on issues, pull requests and schedules, and the one push trigger (`dependency-watch.yml`) is filtered to `package.json` and `package-lock.json`.

## Decisions

Accepted records are binding for humans and agents until a newer record supersedes them. If your task conflicts with one, stop and say so in the issue or pull request. A pull request that changes a decided behaviour adds or supersedes a record. Decisions for this repository alone go in [docs/decisions/](docs/decisions/README.md) (none yet). Decisions that span repositories are core records in [docs/decisions/core/](docs/decisions/core/): the same file in every repository they bind, cited as "core NNNN", and a weekly check compares the copies. This repository holds the ones that bind it:

- [core 0003](docs/decisions/core/0003-guidance-for-agents-and-contributors-lives-in-the-repository.md): `AGENTS.md` is the single entry point and `CLAUDE.md` only imports it; accepted decision records bind humans and agents; guidance is public, with no credentials or tenant details.
- [core 0008](docs/decisions/core/0008-homebrew-installs-prebuilt-release-binaries.md): The formulas install the prebuilt release zip for the user's OS and CPU, pinned by sha256; frodo-cli's pipeline generates and pushes them and nobody edits `Formula/*.rb` by hand.
- [core 0017](docs/decisions/core/0017-security-reports-and-fixes-are-handled-privately-by-a-maintainer.md): Suspected vulnerabilities are reported privately (see `SECURITY.md`); a maintainer owns security reports and unsolicited security fixes, and coding agents and the Concierge do not act on them.
- [core 0018](docs/decisions/core/0018-core-decision-records-are-kept-in-each-repository.md): A decision that binds more than one repository is one identical file in `core/` of every repository it binds; a change to one is made in every repository it binds, in the same change set.

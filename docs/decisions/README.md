# Decision records

A decision record explains one lasting decision: why we chose it, what it means and what we gave up. Records are plain Markdown in the repository, so every contributor and every coding agent, whatever tool it uses, reads the same thing.

This folder holds the decisions that concern **this tap only**. There are none yet. Decisions that bind more than one repository (frodo-cli, frodo-lib, this tap) are core records, kept in the [core/](core/) folder; the section "Core decisions" below lists the ones that bind this repository.

## Rules

- An accepted record is binding for humans and agents until a newer record supersedes it. An agent whose task conflicts with one stops and says so in the issue or pull request.
- Only lasting decisions get a record: something you would be surprised to see reversed without discussion. Not minor implementation notes or routine refactors.
- An accepted record is not edited, except for typos and for a `Known deviations` section, a status note that may be added, edited or removed, without a new record, in the pull request that fixes the deviation or opens its tracking issue ([core 0018](core/0018-core-decision-records-are-kept-in-each-repository.md)). A changed decision is a new record: set the old record's status to `superseded by NNNN` and update the index.
- A pull request that changes a decided behaviour adds or supersedes a record in the same pull request.
- Records are public. No credentials, tenant names, security-incident details or personal information.
- `applies-to:` lists path globs where that helps; `issues:` lists related issues as `owner/repo#N`.

## Writing one

Copy `template.md` to `NNNN-short-title.md` (the next number, starting at 0001), fill it in (aim for under 40 lines) and add a row to the index. Besides the three required sections, a record may have `## Known deviations` and `## Alternatives considered`. `node .github/scripts/validate-decision-records.mjs docs/decisions` checks this folder and its `core/` folder; CI runs the same check.

## Core decisions

Core records bind more than one repository: the same file sits in the `core/` folder of every repository it binds and is cited as "core NNNN". This tap holds only the core records that bind it, plus core 0018, the rule for core records, so the numbers in `core/` have gaps here; a core record that binds this tap is added in the same change set as in the other repositories, and the weekly `Core records drift` workflow compares each file here with the same file in frodo-cli's `docs/decisions/core/`.

The records below are numbered apart from this folder's own records, and a change to one is made in every repository it binds ([core 0018](core/0018-core-decision-records-are-kept-in-each-repository.md)). `.github/scripts/validate-decision-records.mjs` checks their front matter, their sentence in this table and that they bind this tap.

| Number | Title | Status | Applies to | Rule |
| - | - | - | - | - |
| [core 0003](core/0003-guidance-for-agents-and-contributors-lives-in-the-repository.md) | Guidance for agents and contributors lives in the repository | accepted | repository-wide | `AGENTS.md` is the single entry point and `CLAUDE.md` only imports it; accepted decision records bind humans and agents; guidance is public, with no credentials or tenant details. |
| [core 0008](core/0008-homebrew-installs-prebuilt-release-binaries.md) | Homebrew installs prebuilt release binaries | accepted | `Formula/**`, `tools/update-homebrew-formula.mjs` | Homebrew formulas install the prebuilt release zip pinned by sha256; `tools/update-homebrew-formula.mjs` generates them and the pipeline commits them to the tap, never by hand. |
| [core 0017](core/0017-security-reports-and-fixes-are-handled-privately-by-a-maintainer.md) | Security reports and fixes are handled privately by a maintainer | accepted | `SECURITY.md`, `.claude/skills/triage-a-security-report/**` | Suspected vulnerabilities are reported privately (see `SECURITY.md`); a maintainer owns security reports and unsolicited security fixes, and coding agents and the Concierge do not act on them. |
| [core 0018](core/0018-core-decision-records-are-kept-in-each-repository.md) | Core decision records are kept in each repository | accepted | `docs/decisions/core/**`, `decisions/core/**` | A decision that binds more than one repository is one identical file in `core/` of every repository it binds, cited as "core NNNN"; a weekly check compares the copies, a Known deviations section is a status note the pull request that fixes the deviation may edit, and the umbrella repository is archived. |

## Index

| # | Title | Status |
| - | - | - |

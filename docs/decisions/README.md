# Decision records

A decision record explains one lasting decision: why we chose it, what it means and what we gave up. Records are plain Markdown in the repository, so every contributor and every coding agent, whatever tool it uses, reads the same thing.

This folder holds the decisions that concern **this tap only**. There are none yet. Decisions that span repositories (frodo-cli, frodo-lib, this tap) are in [rockcarver/frodo](https://github.com/rockcarver/frodo/tree/main/docs/decisions); the section "Decisions that span repositories" below states, in one sentence each, the ones that bind this repository.

## Rules

- An accepted record is binding for humans and agents until a newer record supersedes it. An agent whose task conflicts with one stops and says so in the issue or pull request.
- Only lasting decisions get a record: something you would be surprised to see reversed without discussion. Not minor implementation notes or routine refactors.
- An accepted record is not edited, except for typos. A changed decision is a new record: set the old record's status to `superseded by NNNN` and update the index.
- A pull request that changes a decided behaviour adds or supersedes a record in the same pull request.
- Records are public. No credentials, tenant names, security-incident details or personal information.
- `applies-to:` lists path globs where that helps; `issues:` lists related issues as `owner/repo#N`.

## Writing one

Copy `template.md` to `NNNN-short-title.md` (the next number, starting at 0001), fill it in (aim for under 40 lines) and add a row to the index. Besides the three required sections, a record may have `## Known deviations` and `## Alternatives considered`. `node .github/scripts/validate-decision-records.mjs docs/decisions` checks the folder; CI runs the same check.

## Decisions that span repositories

A decision that binds more than this repository is recorded once, in the public umbrella repository [rockcarver/frodo](https://github.com/rockcarver/frodo) (`docs/decisions/`). The Repo Concierge's gates read this repository only and never the umbrella, so each umbrella record that binds this repository is stated here in one sentence with a link. When a new umbrella record binds this repository, add its row in the same change set.

| Record | Rule | Status |
| - | - | - |
| [0003](https://github.com/rockcarver/frodo/blob/main/docs/decisions/0003-guidance-for-agents-and-contributors-lives-in-the-repository.md) | `AGENTS.md` is the single entry point and `CLAUDE.md` only imports it; accepted decision records bind humans and agents; guidance is public, with no credentials or tenant details. | accepted |
| [0008](https://github.com/rockcarver/frodo/blob/main/docs/decisions/0008-homebrew-installs-prebuilt-release-binaries.md) | The formulas install the prebuilt release zip for the user's OS and CPU, pinned by sha256; frodo-cli's pipeline generates and pushes them and nobody edits `Formula/*.rb` by hand. | accepted |
| [0017](https://github.com/rockcarver/frodo/blob/main/docs/decisions/0017-security-reports-and-fixes-are-handled-privately-by-a-maintainer.md) | Suspected vulnerabilities are reported privately (see `SECURITY.md`); a maintainer owns security reports and unsolicited security fixes, and coding agents and the Concierge do not act on them. | accepted |

## Index

| # | Title | Status |
| - | - | - |

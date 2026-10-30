# Project scope

## Purpose

This repository is the Homebrew tap for frodo-cli. It holds two formulas, `frodo-cli` (stable) and `frodo-cli-next` (the prerelease channel), that install the prebuilt frodo-cli release binaries on macOS and Linux with `brew install`. frodo-cli's release pipeline generates the formulas and pushes them here. The people who use it install, upgrade and uninstall Frodo with Homebrew.

## In scope

- Installing, upgrading, reinstalling or uninstalling either formula with Homebrew fails or behaves unexpectedly.
- A formula installs the wrong version, a version that is out of date compared with the latest release, or fails its checksum or download.
- `brew audit`, `brew test` or the formulas' `frodo -v` check fail.
- The formulas do not support a platform or CPU that frodo-cli ships a binary for (macOS or Linux, Intel or ARM).
- This repository's own tests, workflows and documentation.

## Out of scope

- A problem with what the `frodo` command does once it runs: a command, an option, its output, its authentication, its prompts, or how it talks to a tenant. These belong in frodo-cli.
- A problem with the frodo-lib JavaScript API. These belong in frodo-lib.
- A hand-edited formula. The release pipeline regenerates the formulas and overwrites any edit, so a change to the formulas is made in frodo-cli's pipeline, not here.

## Needs a maintainer

- The formula installs cleanly but the installed `frodo` fails to start or reports a version that does not match the release. The cause may be the formula, the binary or the release.
- A request for a new formula, a new release channel or support for another package manager.
- A request to change which platforms or CPU architectures the formulas support.

## Where to go instead

- Frodo CLI behaviour: [frodo-cli issues](https://github.com/rockcarver/frodo-cli/issues/new/choose).
- Frodo library behaviour: [frodo-lib issues](https://github.com/rockcarver/frodo-lib/issues/new/choose).
- A suspected security problem: report it privately as described in [SECURITY.md](../../SECURITY.md). Do not open a public issue.

# Security policy

## Reporting a vulnerability

Please report a suspected vulnerability privately, with GitHub's private vulnerability reporting: open the **Security** tab of the repository and choose **Report a vulnerability** ([direct link](https://github.com/rockcarver/homebrew-frodo-cli/security/advisories/new)).

Do not open a public issue or pull request for a suspected vulnerability.

Include, as far as you can:

- the affected formula and version,
- the steps to reproduce it, ideally a small working proof of concept,
- the impact, and
- who controls the input that triggers it (see the threat model below).

## Scope and threat model

This repository is the Homebrew tap for Frodo. Its formulae install [frodo-cli](https://github.com/rockcarver/frodo-cli): the prerelease formula downloads the release's prebuilt binaries with pinned checksums, and the stable formula is moving to the same form (decision record 0008 in the [umbrella repository](https://github.com/rockcarver/frodo/tree/main/docs/decisions)). In scope are problems with the formulae themselves and with how they fetch and verify what they install: a wrong download location, a missing or wrong checksum, or a way for someone else to change what a formula installs.

The threat model of the CLI itself (who is trusted, what counts as attacker input) is in the [frodo-cli security policy](https://github.com/rockcarver/frodo-cli/security/policy). Report problems in the CLI or its MCP server there.

## Out of scope

- Reports that need control of the operator's own machine, command line, environment or files. The person who runs Frodo is trusted.
- Automated scanner output without a working proof of concept.
- Vulnerabilities in third-party dependencies or in Homebrew itself. Please report those upstream.

## What to expect

Frodo is maintained by a small team of volunteers. We answer on a best-effort basis, handle confirmed vulnerabilities through a private advisory, and disclose them after a fix is released. We credit the reporter if they want to be named.

## Unsolicited fix pull requests

We read a pull request that claims to fix a security problem before we run any automated checks on it, and we may close it without merging. Please report the problem privately instead.

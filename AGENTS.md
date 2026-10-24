# homebrew-frodo-cli: instructions for coding agents

The Homebrew tap that installs [frodo-cli](https://github.com/rockcarver/frodo-cli). It is one of the Frodo repositories: [frodo-cli](https://github.com/rockcarver/frodo-cli), [frodo-lib](https://github.com/rockcarver/frodo-lib) and the umbrella [frodo](https://github.com/rockcarver/frodo) (a README and the decision records that span repositories). There is no build: two Ruby formulas and one test.

## Formulas

- `Formula/frodo-cli.rb` is the stable formula. Today it is still the 4.x source build; the first stable release after the pipeline change replaces it with the prebuilt-binary form.
- `Formula/frodo-cli-next.rb` is the prerelease channel. It downloads the release's prebuilt per-platform zips (`on_macos` / `on_linux` blocks with pinned sha256).

## Rules

- **Do not hand-edit the formulas.** frodo-cli's release pipeline (the `homebrew-formula-update` job, which runs `tools/update-homebrew-formula.mjs` in frodo-cli) regenerates them and pushes straight to `main` as `rockcarver-pipeline`. A manual edit is overwritten by the next release. Change the generator in frodo-cli instead.
- **Run `ruby test/version_checks_test.rb`** after any change that touches a formula's `frodo -v` check. It needs no Homebrew.
- **Keep the pipeline's push conflict-free**: it commits only `Formula/*.rb`, so do not add other generated files there, and keep any workflow path-filtered so a formula push never starts one.
- **Never commit credentials, keys or tokens.**

## Decisions

Accepted records are binding for humans and agents until a newer record supersedes them. If your task conflicts with one, stop and say so in the issue or pull request. A pull request that changes a decided behaviour adds or supersedes a record. Decisions for this repository alone go in [docs/decisions/](docs/decisions/README.md) (none yet); decisions that span repositories are in [rockcarver/frodo](https://github.com/rockcarver/frodo/tree/main/docs/decisions). The ones that bind this repository:

- 0003 [Guidance for agents and contributors lives in the repository](https://github.com/rockcarver/frodo/blob/main/docs/decisions/0003-guidance-for-agents-and-contributors-lives-in-the-repository.md)
- 0008 [Homebrew installs prebuilt release binaries](https://github.com/rockcarver/frodo/blob/main/docs/decisions/0008-homebrew-installs-prebuilt-release-binaries.md)

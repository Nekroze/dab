# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project does *not* adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html), opting instead for a rolling release model.

Please indicate the change you have made in a section below entitled `YYYY-MM`.

## 2018-09

First month of life, hello world!

### Changed

- More uniform subcommands and params
- More fleshed out testing
- Config `set` and `add` operations are now idempotent
- Allow version selection of tools via `$DAB_TOOLS_<NAME>_TAG`

### Added

- `subcommander.sh` to handle nested subcommands
- `dab repo group` subcommand
- Initialized Changelog
- Shell completion support for bash, zsh, and fish.

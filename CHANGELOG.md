# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project does *not* adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html), opting instead for a rolling release model.

Please indicate the change you have made in a section below entitled `YYYY-MM`.

## 2018-10

Are you ready to get STABLE!

### Changed

- Split `lib.sh` into parts
- All entry points are now scripts, and are made via `dab repo entrypoint create`
- Use named docker stages
- Changed `dab network destroy` to `dab network recreate` which also brings the network back up
- Cleanup app code
- `subcommander.sh` is now self contained
- `subcommander.sh` now handles all argument routing
- `tools` no longer automatically start services they might interact with
- added/improved docker health checks for services
- improved destroy subcommand when used on specific tools and services
- Moved `dab repo group` subcommand to `dab group`
- Automatically install PKI CA certificate in browsers when possible
- `tools list` and `services list` now have username and password columns for applicable services
- When creating an entrypoint check if anything already exists before writing
- Generate `tools list` and `services list` out dynamically from docker-compose files

### Added

- Execute [ShellCheck](https://github.com/koalaman/shellcheck) before on entry points before executing
- Repo entry points now passes any additional parameters to their corresponding scripts
- `DAB_USER` environment variable containing user that ran the wrapper script
- `services` subcommand that works like tools
- `repo group service` subcommand to add a service dependency that will start before repos
- `environment` config namespace now stores key value environment variables to be loaded
- `pki` subcommand providing a simple interface to a vault backed full PKI
- `pki` subcommands to completion
- `dab services address` subcommand and address output on `dab services start`
- Added `lib/services.sh`
- `gawk` to nix package propagated dependencies
- `--version` and variants are now taken by all commands and gives handy info for debugging
- [yq](https://github.com/mikefarah/yq) to the dab image for yaml bashing

### Fixed

- Listing subcommands on root `dab` command
- Vault containers cli client address
- Prevent network ensure hook from running for null and network subcommands
- `dab shell` now takes multiple parameters like it should
- `$USER` is now set correctly inside dab
- vaultbot vault address param name corrected
- correctly set docker `--interactive` and `--tty` when appropriate
- Cleanup vault and vaultbot containers started by `pki` subcommands
- UID and GID detection in more varied environments

### Changed

## 2018-09

First month of life, hello world!

### Changed

- Brought `dab tools` subcommands in line with the other subcommand UX
- Tools can now be listed via `dab tools list`
- Generate help and usage info for leaf commands
- More uniform subcommands and parameters
- More fleshed out testing
- Configuration `set` and `add` operations are now idempotent
- Allow version selection of tools via `$DAB_TOOLS_<NAME>_TAG`

### Added

- Added [Hashicorp Vault](https://www.vaultproject.io/) and [VaultBot](https://gitlab.com/msvechla/vaultbot) to tools.
- `subcommander.sh` to handle nested subcommands
- `dab repo group` subcommand
- Initialized Changelog
- Shell completion support for bash, zsh, and fish.
# Dab

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![GitHub license](https://img.shields.io/github/license/Nekroze/dab.svg)](https://github.com/Nekroze/dab/blob/master/LICENSE)
[![CircleCI](https://circleci.com/gh/Nekroze/dab.svg?style=shield)](https://circleci.com/gh/Nekroze/dab)
[![Build Status](https://travis-ci.org/Nekroze/dab.svg?branch=master)](https://travis-ci.org/Nekroze/dab)

> The Developer lab.

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)][15]

Dab is a flexible tool for managing multiple interdependent projects and their orchestration, all while providing a friendly user experience and handy devops tools.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Install

Simply download the [dab wrapper script][1] to somewhere in your `PATH` environment variable, for example:

```bash
 $ sudo curl https://raw.githubusercontent.com/Nekroze/dab/master/dab -o /usr/local/bin/dab
 $ sudo chmod 755 /usr/local/bin/dab
```

After this the `dab` command should be available in your shell:

```bash
 $ dab completion
```

If you are an OSX user you will want to set the `DAB_GID` environment variable to `0` to avoid docker access issues and the `DAB_AUTOUPDATE_COMPLETION` environment variable to false as completion is only supported on Linux out of the box.

## Usage

You need only have docker installed and any POSIX compliant shell to run the wrapper scripts and get going with dab. This will start the dab container and forward all arguments into it:

```bash
 $ dab --help
```

If you do not need to build the docker image yourself and just want to use dab, the [dab script][1] we just executed is all that is needed and can be used from (or moved to) any location.

It is recommended you add the directory containing the [dab script][1] to your shell's `PATH` environment variable.

### Demoing

If you are not yet sure if Dab is right for you, [Play With Docker (PWD)][15] will allow you to spin up a temporary cloud server with Dab available. You will be presented with a terminal containing the latest version of Dab ready to use.

### Setting up a project

As a developer I work on a heaps of projects each with their own needs and quirks. Lets use `dab` to manage a project for us, first we need to register its existence:

```bash
 $ dab repo add containaruba https://github.com/Nekroze/containaruba.git
```

This will register the `containaruba` repository and attempt to clone it into `$DAB_REPO_PATH` which defaults to `~/dab`.

Now we can set the type of entrypoint we want this repo to use.

```bash
 $ dab repo entrypoint create containaruba
 $ dab config add repo/containaruba/entrypoint/start ./test.sh
```

Now whenever we start this repo, or a repo that depends upon this one, the `test.sh` script within the root of the containaruba repo will be executed.

```bash
 $ dab repo entrypoint start containaruba
```

### Using dockerized apps

There is an ever growing selection of tools and services dab provides (checkout `dab apps list`) for recording metrics, databases, etc.

```bash
 $ dab apps start grafana
 $ dab apps start ntopng
 $ dab apps start redis
```

### Updating

Dab has a self updating mechanism in that it will pull the latest version of the dab image when dab is next executed a day or more after the last time it checked. So generally you do not have to do anything at all to stay up to date with the latest features, bug fixes, and security improvements. This new image will update the wrapper script if necessary.

### Watching and Learning

The [Dab UX][16] project stores user experience tests that should almost always be added to and not modified or removed. This allows for a stable command line interface with a clear notification if that interface changes in the form of changes to that project. Each version of Dab itself is tested against the current tests in [Dab UX][16] before released to ensure no regression. These tests are also used to generate the [Dab UX Website][17] where you can learn more about what Dab can do for you.

### Features

- Only depends on docker and a small wrapper script
- Manage code repositories
- Manage entrypoints into repositories eg. starting and stopping a project
- Easy tool access like [CyberChef](https://gchq.github.io/CyberChef/)
- Easy service access like [Redis](https://redis.io/)
- Auto update of dab image
- Setup of private lab network
- Automatically collect logs to explore via [TICK][3] and [Logspout][4]
- Automatically update out of date wrapper script
- Groups allow combining repositories, and even groups to be orchestrated together
- Shared base image, most all docker container dab uses utilize an alpine base image that is lean
- Simple, thanks to the [subcommander][7] dispatcher most subcommands are implemented in only a few SLOC
- Tree structured configuration that can be shared (eg. via git or tar)
- Managed x509 PKI

## Contributing

If you would like to help hone dab into a better tool check out our [contributing][2] documentation.

## Bill Of Materials

The following projects are used to write dab:

- [Subcommander][7]
- [ContainAruba][8]
- [docker-compose-gen][9]
- [yq][10]
- [jq][11]
- [docker-compose][12]
- [shellcheck][13]
- [complete][14]

[1]: https://github.com/Nekroze/dab/raw/master/dab
[2]: https://github.com/Nekroze/dab/blob/master/CONTRIBUTING.md
[3]: https://www.influxdata.com/time-series-platform/
[4]: https://github.com/gliderlabs/logspout
[5]: https://www.vaultproject.io/
[6]: https://gitlab.com/msvechla/vaultbot
[7]: https://github.com/Nekroze/subcommander
[8]: https://github.com/Nekroze/containaruba
[9]: https://github.com/Nekroze/docker-compose-gen
[10]: https://github.com/kislyuk/yq
[11]: https://stedolan.github.io/jq/
[12]: https://github.com/docker/compose
[13]: https://github.com/koalaman/shellcheck
[14]: https://github.com/posener/complete
[15]: http://play-with-docker.com/?stack=https://raw.githubusercontent.com/Nekroze/dab/master/tests/pwd.yml
[16]: https://github.com/Nekroze/dabux
[17]: https://nekroze.github.io/DabUX/

## Maintainers

[@Nekroze](https://github.com/Nekroze)

## Contributing

See [the contributing file](contributing.md)!

PRs accepted.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

GPLv3 © 2018 Taylor Lawson

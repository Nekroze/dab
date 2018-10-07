# Dab

[![GitHub license](https://img.shields.io/github/license/Nekroze/dab.svg)](https://github.com/Nekroze/dab/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/Nekroze/dab.svg)](https://github.com/Nekroze/dab/issues) [![GitHub stars](https://img.shields.io/github/stars/Nekroze/dab.svg)](https://github.com/Nekroze/dab/stargazers) [![Docker Image Size](https://images.microbadger.com/badges/image/nekroze/dab.svg)](https://microbadger.com/images/nekroze/dab "Get your own image badge on microbadger.com") [![CircleCI](https://circleci.com/gh/Nekroze/dab.svg?style=svg)](https://circleci.com/gh/Nekroze/dab) [![Build Status](https://travis-ci.org/Nekroze/dab.svg?branch=master)](https://travis-ci.org/Nekroze/dab)

The Developer lab.

Dab is a flexible tool for managing multiple interdependent projects and their orchestration, all while providing a friendly user experience and handy devops tools.

## Usage

You need only have docker installed and any POSIX compliant shell to run the wrapper scripts and get going with dab. This will start the dab container and forward all arguments into it:

```bash
 $ dab --help
```

If you do not need to build the docker image yourself and just want to use dab, the [dab script][1] we just executed is all that is needed and can be used from (or moved to) any location.

It is recommended you add the directory containing the [dab script][1] to your shell's `PATH` environment variable.

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

### Using tools

There is an ever growing selection of tools dab provides (checkout `dab tools list`) for recording metrics, debugging, etc.

```bash
 $ dab tools start grafana
 $ dab tools start ntopng
 $ dab tools start sysdig
```

### Installing

Simply download the [dab wrapper script][1] to somewhere in your `PATH` environment variable, for example:

```bash
 $ sudo curl https://github.com/Nekroze/dab/blob/master/dab -o /usr/bin/dab
 $ sudo chmod 755 /usr/bin/dab
```

After this the `dab` command should be available in your shell:

```bash
 $ dab completion --help
```

### Updating

Dab has a self updating mechanism in that it will pull the latest version of the dab image when dab is next executed a day or more after the last time it checked. So generally you do not have to do anything at all to stay up to date with the latest features, bug fixes, and security improvements.

The [dab script][1] wrapper has been designed to reduce the requirement to update it when new features are added to dab, however it may be necessary to do so on occasion and can be accomplished simply by downloading the latest version of the file and replace the existing one on your machine. Executing the install steps again should suffice.


### Features

- Only depends on docker and a small wrapper script
- Manage code repositories
- Easy tool access like [CyberChef](https://gchq.github.io/CyberChef/)
- Easy service access like [Redis](https://redis.io/)
- Auto update of dab image
- Setup of private lab network
- Automatically collect logs to explore via [TICK][3] and [Logspout][4]
- Automatically detect out of date wrapper script
- Groups allow combining repositories, services, and tools to be orchestrated together
- Shared base image, most all tools and services along with dab itself uses an alpine base image that is auto updated
- Simple, thanks to the `subcommander.sh` dispatcher most subcommands are implemented in only a couple SLOC
- Tree structured configuration that can be shared
- x509 PKI managed via [Vault][5] with transparent certificate renewal via [VaultBot][6]

## Contributing

If you would like to help hone dab into a better tool check out our [contributing][2] documentation.


[1]: https://github.com/Nekroze/dab/blob/master/dab
[2]: https://github.com/Nekroze/dab/blob/master/CONTRIBUTING.md
[3]: https://www.influxdata.com/time-series-platform/
[4]: https://github.com/gliderlabs/logspout
[5]: https://www.vaultproject.io/
[6]: https://gitlab.com/msvechla/vaultbot

# Dab

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![GitHub license](https://img.shields.io/github/license/Nekroze/dab.svg)](https://github.com/Nekroze/dab/blob/master/LICENSE)
[![CircleCI](https://circleci.com/gh/Nekroze/dab.svg?style=shield)](https://circleci.com/gh/Nekroze/dab)
[![Build Status](https://travis-ci.org/Nekroze/dab.svg?branch=master)](https://travis-ci.org/Nekroze/dab)
[![Gitter chat](https://badges.gitter.im/Nekroze/dab.png)](https://gitter.im/developer-lab)

> The Developer lab.

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)][15]

The Developer Laboratory makes creating, sharing, and using a portable, reproducible local development environment. Everything runs in docker and is configured using simple files that can be version controlled and shared with friends or colleagues.

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

If you want to execute `dab` with `sudo` and retain set environmental variables, you can use the following to execute dab:
```bash
 $ sudo -E dab --help
```

## Stable Updates Stream

The latest image is built off of the ever changing master branch. While all efforts are made to keep the UI and behaviour stable, you may wish to use the `stable` docker tag (and thus git branch) which receives periodic merges from the master branch.

You can control the image to be used with the `DAB_IMAGE_TAG` environment variable like so:

```bash
export DAB_IMAGE_TAG=stable
```


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

## Customization

Dab supports various means of customization primarily through environment variables.

Any exported environment variable starting with `DAB_` will be passed into any dab container by the wrapper. You can also set environment variables without altering your shell(s) by writing to the dab config. For example any file in the config directory (defaults to `~/.config/dab` but customizable via the `$DAB_CONF_PATH` environment variable) under a directory called `environment` (so `~/.config/dab/environment` by default) will be loaded as Dab starts into env vars where the filename is the name of the env var and the contents of the file its value.

Once you are passing in environment variables they can be used to tweak a great many knobs. For example most dockerized apps can have their version changed or their settings altered, try `dab apps config` to explore your options.

The following is an (incomplete) list of environment variables dab knows about and what they do:

- `DAB_UMASK` Change the umask of the process running in a dab container.
- `DAB_UID` Change the user id (uid) running in the dab container.
- `DAB_GID` Change the group id (gid) running in the dab container.
- `DAB_USER` Change the user name running in the dab container.
- `DAB_AUTOUPDATE` can be set to either `'true'` or `'false'` to enable or disable all auto updating.
- `DAB_AUTOUPDATE_IMAGE` can be set to either `'true'` or `'false'` to enable or disable dab image auto updating.
- `DAB_AUTOUPDATE_WRAPPER` can be set to either `'true'` or `'false'` to enable or disable wrapper auto updating.
- `DAB_AUTOUPDATE_COMPLETION` can be set to either `'true'` or `'false'` to enable or disable completion auto updating.
- `DAB_TIPS` can be set to either `'true'` or `'false'` to enable or disable once hourly tips.
- `DAB_TIPS_BUILTIN` can be set to either `'true'` or `'false'` to enable or disable the builtin set of tips.
- `DAB_PROFILING` if set to `true` the time at the start and stop of major functions is displayed.
- `DAB_DEBUG` if set to `true` then every thing dab executes is displayed before hand via `set -x`.
- `DAB_APPS_*` Is a glob pattern, many apps can be tweaked such as the version, try `dab apps config` to find uses.
- `DAB_APPS_<NAME>_*` Is a glob pattern where NAME is an app name, the prefix is removed and passed into the apps container.
- `DAB_REPO_PATH` path to your dab managed repos, defaults to `~/dab`.
- `DAB_DEFAULT_REMOTE` the remote to use when interacting with git, defaults to origin.
- `DAB_IMAGE_NAMESPACE` image user/namespace, defaults to `nekroze`.
- `DAB_IMAGE_NAME` the name of the image under the namespace for dab.
- `DAB_IMAGE_TAG` the docker image tag to use, defaults to `latest`.
- `DAB_IMAGE` the dab image to use, defaults to `$DAB_IMAGE_NAMESPACE/$DAB_IMAGE_NAME:$DAB_IMAGE_TAG`.
- `DAB_LAB_INTERNET` is a boolean switch that toggles external routing on the `lab` network, defaults to false.
- `DAB_LAB_SUBNET` CIDR describing the shape and size of th3 `lab` network, defaults to `10.10.0.0/16`.
- `DAB_UMASK` allows tweaking the umask to run as in the dab container.

The environment can be further customized by setting specific config keys.

- `repo/<NAME>/tip` if set a repo will checkout the value after clone and compare against this for `dab repo report` status `uptodate`.
- `repo/<NAME>/website` if set this will be displayed in `dab repo list`.
- `repo/<NAME>/remotes/<REMOTENAME>` if set dab will ensure this repo has a remote named from what you put instead of `<REMOTENAME>` with a url it gets from the value of this key.
- `tips/custom` is a list of custom tips to be mixed in with dab's tips.
- `apps/<NAME>` some apps will mount a path under this config namespace such as kubernetes.


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

## Maintainers

- [@Nekroze](https://github.com/Nekroze)
- [@grke](https://github.com/grke)
- [@slt](https://github.com/slt)
- [@Lachlan-S](https://github.com/Lachlan-S)
- [@tommymcguiver](https://github.com/tommymcguiver)

## Contributing

See [the contributing file][2]!

Pull Requests accepted without corresponding issues provided they are well explained and reasoned.

Small note: If editing the README, please conform to the [standard-readme][19] specification.

## License

[GPLv3 © 2018 Taylor Lawson][18]

[1]: dab
[2]: CONTRIBUTING.md
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
[18]: LICENSE
[19]: https://github.com/RichardLitt/standard-readme

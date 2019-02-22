# Developing Dab

I would first like to thank you for considering contributing to Dab.

I suggest hitting that fork button if you are reading this. I find it best to make any changes in a new branch and opening a pull request from your fork's custom branch to the master branch of the [upstream repository][3]. Pull requests (and any new changes to your fork's custom branch) are automatically tested in the cloud via CircleCI with results displayed in the pull request.

## Community Structure

This project's original Author is [Taylor Lawson][7] (aka @Nekroze) who is the also currently the Owner (aka Administrator) of the project's [Upstream][8] repository.

The following users are also Maintainers of the [Upstream][8] project allowing them to review and accept Pull Requests to the `master` or `stable` branches:
- @Nekroze
- @grke

Contributions to Dab itself however can be done by anyone with a github account, simply fork the repository so that you have full access to your own copy where you can create a new branch for your changes, following [GitHub Flow][9] to keep the process clean and simple.

## Architecture

Looking top down, the starting point for each run is the [dab wrapper script](./dab) which is a POSIX compliant shell script that uses only standard GNU tools (eg. grep) to generate the appropriate [docker][1] [run][2] command to run the Dab [docker image][3] which stores the rest of the application. This allows for a predictable environment in which Dab can run while also removing the need to manage any dependencies Dab may have, other than [docker][1] obviously.

Only the [app directory](./app) will end up in the docker image wherein [Subcommander][6] will be executed to handle input, usually distributing parameters to one of the scripts in the [subcommands directory](./app/subcommands/) via [subcommander](./app/subcommander.sh) to do the real work. The [subcommands directory](./app/subcommands/) tree is the structure of Dab subcommands using files and directories, see [Subcommander][6] for more on how this works but it is sufficient to know that each subcommand is a executable file with a shebang (eg. `#!/bin/sh`) that will be executed when the appropriate Dab command is run. 

All subcommands should be POSIX compliant shell scripts and run under `set -e` to ensure errors are not ignored.

Common functionality is stored in a [library directory](./app/lib) providing functions for things such as; recursive dab executing, config reading and writing, output color helpers, and more.

## Style

Shell script style is enforced at docker image build time by [shfmt][4] and tests written in gherkin feature files are checked by [cucumber linter][5] at test image build time.

## Building

Most changes to Dab will require the image to be rebuilt and can be done via the build script:

```bash
 $ ./scripts/build.sh
```

However if you are executing the [dab wrapper script](./dab) and your current working directory is the `dab` git repository then a volume mount will be configured to expedite affecting any changes without needing a rebuild, although it will be required for changes to the [Dockerfile](./Dockerfile).

## Running the regression test suite

Additionally, to run the suite of regression tests execute:

```bash
 $ ./scripts/test.sh
```

By default it will run on your machine directly, this is fast but interacts with your local docker volumes potentially causing loss of data you may want to keep eg. postgres app data. Another method is to use docker in docker so as not to affect your normal use of Dab, this is however much slower. This is configured by setting the `TEST_DOCKER` environment variable to `dind` before running the `./scripts/test.sh` script.

You may also pass a specific tag selection or feature file path relative to the `tests` directory for example to run the scenario defined on line 21 of the `misc.feature` file of tests you can run the following:

```bash
 $ ./scripts/test.sh features/misc.feature:21
```

## Design

This section documents some of the design decisions and trade-offs that have been made as a way to explain past decisions and guide in the future.

The subcommands are laid out in a [directory and file tree structure](app/subcommands) that [Subcommander][6] uses to automatically generate the shape of the application. This means that creating new subcommands is as simple as creating a script in the right place or a directory for a namespace, without also having to keep some map of commands to files that risks drifting and becoming incorrect.

Dockerized apps are defined one at a time as a docker-compose file in the [docker](app/docker) directory where the name of the app is extracted from the filename, so `docker-compose.postgres.yml` means that an app called postgres is then made available. Apps should have at least the `description` label defined which is used to generate the output of `dab apps list` and may contain a backtick to separate columns should you need to provide a default username and password for the app. Apps should not bind to a specific host port as this can cause conflicts, instead they should simply `expose` any ports they listen on which will make them displayed to the user thanks to `ishmael address` which prefixes each address with the value of the containers `exposing` label or `http` schema if not defined.

Completion is handled by "the completion binary" which is a go based application defined in the [completion](completion) directory. The subcommands must be manually defined to match the [subcommands directory tree](app/subcommands), other files in the [completion](completion) directory defined functions or static lists for generating completions on various arguments to subcommands. For example [apps.go](completion/apps.go) defines an array of each app that must be added to when a new app is added to dab. For an example of arguments to subcommands [repos.go](completion/repos.go) defines functions to find all defined repos in the users dab config and suggest them for completion to the subcommands that can take them.

Functionality shared across subcommands should be placed in a library file to be sourced from the [libraries dir](app/lib) however if the functionality is only used by one subcommand then it should exist within the subcommand script itself to keep the definition close to the usage.

## Maintainers

AKA Collaborators in GitHub parlance, these users have the ability to review and accept pull requests to the master and stable branches. This section describes some of the process they will go through when considering a pull request.

Each Pull Request should contain the minimum number of commits (each commit being one logical change (meaning no implementing commit plus 2 fix commits, squash them into one) with sufficiently descriptive short (first line of) commit messages suitable to be read on their own in the `dab changelog` or `dab update` output.

When merging a Pull Request the drop-down will be used to select "Rebase and Merge" instead of any of the other options to avoid creating merge commits complicating the git graph used in the `dab changelog` or `dab update` output.

[1]: https://docker.com
[2]: https://docs.docker.com/engine/reference/run
[3]: https://hub.docker.com/r/nekroze/dab
[4]: https://github.com/mvdan/sh
[5]: https://github.com/charlierudolph/cucumber_lint
[6]: https://github.com/Nekroze/subcommander
[7]: https://keybase.io/nekroze
[8]: https://github.com/Nekroze/dab
[9]: https://guides.github.com/introduction/flow/

# Developing Dab

I would first like to thank you for considering contributing to Dab.

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

By default it will run with docker in docker so not to affect your normal use of Dab, this is however very slow. If you feel adventurous you can set `TEST_DOCKER` environment variable to `local` before running the `./scripts/test.sh` script to run on your machines local docker instance which should be much faster.

You may also pass a specific tag selection of feature file path relative to the `tests` directory.

[1]: https://docker.com
[2]: https://docs.docker.com/engine/reference/run
[3]: https://hub.docker.com/r/nekroze/dab
[4]: https://github.com/mvdan/sh
[5]: https://github.com/charlierudolph/cucumber_lint
[6]: https://hub.docker.com/r/nekroze/subcommander

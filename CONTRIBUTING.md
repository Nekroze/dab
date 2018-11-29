# Developing Dab

I would first like to thank you for considering contributing to Dab.

## Architecture

Looking top down, the entry point for each run is the [dab script](./dab) which is a POSIX compliant shell script that uses only standard GNU tools (eg. grep) to generate the appropriate [docker][1] [run][2] command to run the dab [docker image][3] which stores the rest of the application. This allows for a predictable environment in which dab can run while also removing the need to manage any dependencies dab may have, other than [docker][1] of cause.

Only the [app directory](./app) will end up in the docker image wherein subcommander will be executed to handle input, usually distributing parameters to one of the scripts in the [subcommands directory](./app/subcommands/) via [subcommander](./app/subcommander.sh) to do the real work.

All scripts should be POSIX compliant and run under `set -e` to ensure errors are not ignored.

Common functionality is stored in a [library directory](./app/lib) providing functions for things such as; recursive dab executing, config reading and writing, output colorizers, and more.

## Style

Shell script style is enforced at docker image build time by [shfmt][4] and tests written in gherkin feature files are checked by [cucumber linter][5] at test image build time.

## Building

Most changes to dab will require the image to be rebuilt and can be done via the build script:

```bash
 $ ./scripts/build.sh
```

However if you are executing the [dab script](./dab) and your current working directory is the `dab` git repository then a volume mount will be configured to expedite affecting any changes without a build.

## Running the regression test suite

Additionally, to run the suite of regression tests execute:

```bash
 $ ./scripts/test.sh
```

By default it will run with docker in docker so not to affect your normal use of dab, this is however very slow. If you feel adventurous you can set `TEST_DOCKER` environment variable to `local` before running the `./scripts/test.sh` script to run on your machines local docker instance which should be much faster.

[1]: https://docker.com
[2]: https://docs.docker.com/engine/reference/run
[3]: https://hub.docker.com/r/nekroze/dab
[4]: https://github.com/mvdan/sh
[5]: https://github.com/charlierudolph/cucumber_lint

# First two stages are for testing shell script syntax and format.
FROM koalaman/shellcheck-alpine:stable

WORKDIR /mnt

# Copy in the whole project for analysis.
COPY ./ ./

RUN shellcheck --shell sh --color dab $(find . -name '*.sh' -type f)

# Second analysis stage runs shfmt to ensure a consistent style.
FROM golang:alpine

# Install shfmt https://github.com/mvdan/sh and git.
RUN apk add --no-cache git \
 && go get -v mvdan.cc/sh/cmd/shfmt/...

# Copy in the whole project for analysis.
COPY ./app ./

# display diffs of any files that do not conform to a posix compliant
# simplified style.
RUN shfmt -d -ln=posix -s .

# Final stage prepares an image to run aruba via cucumber.
FROM ruby:2.5

# Install docker-ce.
RUN apt-get update \
 && apt-get install -y \
    apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	software-properties-common \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && apt-key fingerprint 0EBFCD88 \
 &&  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" \
 && apt-get update \
 && apt-get install -y docker-ce \
 && rm -rf /var/lib/apt/lists/* \
 && gem install cucumber_lint

WORKDIR /usr/src/app

# Build deps in seperate layer to utilize docker caching.
COPY tests/Gemfile* ./
# error if Gemfile has been modified since Gemfile.lock was last updated.
RUN bundle config --global frozen 1 \
 && bundle install

COPY ./features ./features

# Check to ensure feature files are well formatted.
RUN cucumber_lint

# Only copy in the wrapper script to approximate the end user experience.
COPY ./dab ./dab

ENTRYPOINT ["/usr/local/bundle/bin/cucumber","--color","--fail-fast","--strict","--guess","--verbose"]
# Allows targeting of specific features via the command input.
CMD ["features"]

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="dab-tests" \
      org.label-schema.description="The Developer Lab, Test Suite" \
      org.label-schema.usage="/usr/src/app/README.md" \
      org.label-schema.url="https://github.com/Nekroze/dab" \
      org.label-schema.vcs-url="https://github.com/Nekroze/dab.git" \
      org.label-schema.vendor="Taylor 'Nekroze' Lawson <https://keybase.io/nekroze>"

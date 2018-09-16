# First two stages are for testing shell script syntax and format.
# Prevents broken images from being created.
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


# Selected alpine for a small base image that many other images also use
# maximizing docker cache utilization.
FROM alpine:latest

# Docker and docker-compose are always required but take a while to install so
# they are to be kept at a lower layer for caching.
RUN apk add --no-cache docker python3 \
 && pip3 install docker-compose

# Misc tools required for scripts.
RUN apk add --no-cache git openssh tree util-linux

# Inside the dab container, user configurable paths are
# mounted to consistent locations. And some handy defaults.
ENV \
	DAB_REPO_PATH="/var/dab/repos" \
	DAB_CONF_PATH="/etc/dab" \
	PS1='\[\e[33m\]\A\[\e[m\] @ \[\e[36m\]\h\[\e[m\] \[\e[35m\]\\$\[\e[m\] ' \
	COMPOSE_PROJECT_NAME=dab
VOLUME "$DAB_REPO_PATH" "$DAB_CONF_PATH"

# Move just the app directory from the dab repository and execute from there to
# keep paths consistent and predictable.
WORKDIR /opt/dab
COPY ./app ./README.md ./LICENSE ./
ENTRYPOINT ["/opt/dab/main.sh"]

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="dab" \
      org.label-schema.description="The Developer Lab" \
      org.label-schema.usage="/opt/dab/README.md" \
      org.label-schema.url="https://github.com/Nekroze/dab" \
      org.label-schema.vcs-url="https://github.com/Nekroze/dab.git" \
      org.label-schema.vendor="Taylor 'Nekroze' Lawson <https://keybase.io/nekroze>"

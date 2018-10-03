# First two stages are for testing shell script syntax and format.
# Prevents broken images from being created.
FROM koalaman/shellcheck-alpine:stable AS shellcheck

WORKDIR /mnt

# Copy in the whole project for analysis.
COPY ./ ./

RUN shellcheck --shell sh --color dab $(find . -name '*.sh' -type f)


# Second analysis stage runs shfmt to ensure a consistent style.
FROM golang:latest AS shfmt

# Install shfmt https://github.com/mvdan/sh and git.
RUN go get -v mvdan.cc/sh/cmd/shfmt/...

# Copy in the whole project for analysis.
COPY ./app ./app

# display diffs of any files that do not conform to a posix compliant
# simplified style.
RUN shfmt -d -ln=posix -s .


# Third stage for compiling shell completion binary.
FROM golang:latest AS completion
WORKDIR $GOPATH/src/app/completion

# Install golangci-lint
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin latest

# Test, lint, and build the shell completion binary.
COPY ./completion/*.go ./
RUN go get -d -v ./... \
 && go test ./... \
 && golangci-lint run --deadline '2m' --enable-all \
 && go build -o completion .


# Selected alpine for a small base image that many other images also use
# maximizing docker cache utilization.
FROM alpine:latest AS main

# Docker and docker-compose are always required but take a while to install so
# they are to be kept at a lower layer for caching.
RUN apk add --no-cache docker python3 ca-certificates \
 && rm -f /usr/bin/dockerd /usr/bin/docker-containerd* \
 && pip3 install docker-compose

# Misc tools required for scripts.
RUN apk add --no-cache git openssh tree util-linux jq

# Handy env var configs
ENV DAB="/opt/dab" \
    PS1="\[\e[33m\]\A\[\e[m\] @ \[\e[36m\]\h\[\e[m\] \[\e[35m\]\\$\[\e[m\] " \
	PATH="$PATH:/opt/dab/docker"

# Move just the app directory from the dab repository and execute from there to
# keep paths consistent and predictable.
WORKDIR /opt/dab
COPY --from=shellcheck /bin/shellcheck /usr/bin/
COPY --from=completion /go/src/app/completion ./
COPY ./app ./README.md ./LICENSE ./dab ./
ENTRYPOINT ["/opt/dab/main.sh"]

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="dab" \
      org.label-schema.description="The Developer Lab" \
      org.label-schema.usage="/opt/dab/README.md" \
      org.label-schema.url="https://github.com/Nekroze/dab" \
      org.label-schema.vcs-url="https://github.com/Nekroze/dab.git" \
      org.label-schema.vendor="Taylor 'Nekroze' Lawson <https://keybase.io/nekroze>"

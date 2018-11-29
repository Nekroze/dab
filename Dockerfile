# First two stages are for testing shell script syntax and format.
# Prevents broken images from being created.
FROM koalaman/shellcheck-alpine:stable AS shellcheck

WORKDIR /mnt

# Copy in the whole project for analysis.
COPY ./ ./

RUN shellcheck --shell sh --color dab $(find . -name '*.sh' -type f)


# Second analysis stage runs shfmt to ensure a consistent style.
FROM golang:latest AS shfmt

# Install shfmt https://github.com/mvdan/sh
RUN go get -v mvdan.cc/sh/cmd/shfmt/...

# Copy in the whole project for analysis.
COPY ./ ./

# display diffs of any files that do not conform to a posix compliant
# simplified style.
RUN shfmt -d -ln=posix -s .


# Third stage for compiling shell completion binary.
FROM golang:latest AS completion
WORKDIR $GOPATH/src/app/completion

# Install golangci-lint
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v1.12.2
ENV GO111MODULE=on

# Test, lint, and build the shell completion binary.
COPY ./completion/*.go ./
COPY ./go.mod ./go.sum ./

RUN golangci-lint run --deadline '2m' --enable-all --disable dupl,lll,gochecknoglobals,gochecknoinits  \
 && go build -o completion . \
 && CGO_ENABLED=0 GOOS=linux GOARCH=386 go build \
   -a -installsuffix cgo -ldflags='-w -s' -o /usr/bin/dab-completion -v \
   .


# This phase generates versioning artifacts from git.
FROM alpine:latest AS versioning

RUN apk add --no-cache git

COPY ./.git ./

RUN git rev-parse HEAD > /VERSION \
 && git clone https://github.com/Nekroze/dab.git \
 && cd dab \
 && git log --graph --pretty=format:'\e[0;31m%h\e[0m|↓|%s \e[0;34m<%an>\e[0m' --abbrev-commit | tac > /LOG


# Used to pull in the docker-compose-gen binary
FROM nekroze/docker-compose-gen:latest AS gen

# Used to pull in the ishmael binary
FROM nekroze/ishmael:v1.2.1 AS ishmael

# Selected alpine for a small base image that many other images also use
# maximizing docker cache utilization.
FROM alpine:latest AS main

RUN apk add --no-cache git

# Misc tools required for scripts.
RUN apk add --no-cache openssh tree util-linux jq nss-tools multitail \
 && echo "check_mail:0" >> /etc/multitail.conf

# Docker and docker-compose are always required but take a while to install so
# they are to be kept at a lower layer for caching.
RUN apk add --no-cache docker python3 ca-certificates \
 && rm -f /usr/bin/dockerd /usr/bin/docker-containerd* \
 && pip3 install docker-compose

# Handy env var configs
ENV DAB="/opt/dab" \
    PS1="\[\e[33m\]\A\[\e[m\] @ \[\e[36m\]\h\[\e[m\] \[\e[35m\]\\$\[\e[m\] " \
    PATH="$PATH:/opt/dab/bin"

# subcommander env vars
ENV APPLICATION="dab" \
    SUBCOMMANDS="/opt/dab/subcommands" \
    HOOK="/opt/dab/bin/pre-hook" \
    DESCRIPTION="The Developer Laboratory\n\n\
Dab is a flexible tool for managing multiple interdependent projects and their orchestration execution, all while providing a friendly user experience and handy devops tools."

# Move just the app directory from the dab repository (along with some other
# file from previous layers) and execute from there to keep paths consistent
# and predictable.
WORKDIR /opt/dab
ADD https://github.com/mikefarah/yq/releases/download/2.1.1/yq_linux_amd64 /usr/bin/yq
ADD https://raw.githubusercontent.com/Nekroze/subcommander/master/subcommander /usr/bin/subcommander
RUN chmod 755 /usr/bin/yq /usr/bin/subcommander \
 && chmod 666 /etc/passwd
COPY --from=shellcheck /bin/shellcheck /usr/bin/
COPY --from=completion /usr/bin/dab-completion /usr/bin/dab-completion
COPY --from=ishmael /app /usr/bin/ishmael
COPY --from=gen /app /usr/bin/docker-compose-gen
COPY --from=versioning /VERSION /LOG /
COPY ./app ./README.md ./LICENSE ./dab ./
ENTRYPOINT ["/usr/bin/subcommander"]

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="dab" \
      org.label-schema.description="The Developer Lab" \
      org.label-schema.usage="/opt/dab/README.md" \
      org.label-schema.url="https://github.com/Nekroze/dab" \
      org.label-schema.vcs-url="https://github.com/Nekroze/dab.git" \
      org.label-schema.vendor="Taylor 'Nekroze' Lawson <https://keybase.io/nekroze>"

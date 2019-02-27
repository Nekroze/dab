# First two stages are for testing shell script syntax and format.
# Prevents broken images from being created.
FROM koalaman/shellcheck-alpine:stable AS shellcheck

WORKDIR /mnt

# Copy in the whole project for analysis.
COPY ./ ./

RUN shellcheck --shell sh --color \
      dab app/bin/* \
      $(find . -name '*.sh' -type f) \
      $(find app/subcommands -type f)


# Second analysis stage runs shfmt to ensure a consistent style.
FROM golang:latest AS shfmt

# Install shfmt https://github.com/mvdan/sh
RUN go get mvdan.cc/sh/cmd/shfmt

# Copy in the whole project for analysis.
COPY ./ ./

# display diffs of any files that do not conform to a posix compliant
# simplified style.
RUN shfmt -d -ln=posix -s .


# Third stage for compiling shell completion binary.
FROM golang:latest AS completion
WORKDIR $GOPATH/src/app/completion

# Install golangci-lint
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v1.15.0
ENV GO111MODULE=on

# Test, lint, and build the shell completion binary.
COPY ./completion ./

RUN golangci-lint run --deadline '2m' --enable-all --disable dupl,lll,gochecknoglobals,gochecknoinits  \
 && go build -o completion . \
 && CGO_ENABLED=0 GOOS=linux GOARCH=386 go build \
   -a -installsuffix cgo -ldflags='-w -s' -o /usr/bin/dab-completion \
   .


# This phase generates versioning artifacts from git.
FROM alpine:latest AS versioning

RUN apk add --no-cache git

COPY ./.git ./

RUN git rev-parse HEAD > /VERSION \
 && git clone https://github.com/Nekroze/dab.git \
 && cd dab \
 && git log --graph --pretty=format:'\e[0;31m%h\e[0m|↓|%s \e[0;34m<%an>\e[0m' --abbrev-commit | tac > /LOG

# Stage some files here so that the final image has less layers
FROM alpine:latest AS prep

RUN apk add --no-cache curl gettext bash openssl

ADD https://raw.githubusercontent.com/Nekroze/subcommander/master/subcommander /usr/bin/subcommander
ADD https://raw.githubusercontent.com/helm/helm/master/scripts/get /bin/get-helm
WORKDIR /usr/bin
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
 && chmod 755 /usr/bin/subcommander /usr/bin/kubectl /bin/get-helm \
 && env HELM_INSTALL_DIR=/usr/bin get-helm

COPY --from=shellcheck /bin/shellcheck /usr/bin/shellcheck
COPY --from=completion /usr/bin/dab-completion /usr/bin/dab-completion
COPY --from=nekroze/ishmael:v1.2.2 /app /usr/bin/ishmael
COPY --from=nekroze/docker-compose-gen:latest /app /usr/bin/docker-compose-gen


# Selected alpine for a small base image that many other images also use
# maximizing docker cache utilization.
FROM alpine:latest AS main

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="dab" \
      org.label-schema.description="The Developer Lab" \
      org.label-schema.usage="/opt/dab/README.md" \
      org.label-schema.url="https://github.com/Nekroze/dab" \
      org.label-schema.vcs-url="https://github.com/Nekroze/dab.git" \
      org.label-schema.vendor="Taylor 'Nekroze' Lawson <https://keybase.io/nekroze>"

# Docker and docker-compose are always required but take a while to install so
# they are to be kept at a lower layer for caching.
RUN apk add --no-cache docker python3 \
 && rm -f /usr/bin/dockerd /usr/bin/docker-containerd* \
 && pip3 install docker-compose asciinema \
 && rm -rf ~/.cache

# Misc tools required for scripts.
RUN apk add --no-cache git openssh tree util-linux jq nss-tools multitail ca-certificates highlight libintl entr postgresql-client \
 && pip3 install yq \
 && echo "check_mail:0" >> /etc/multitail.conf \
 && chmod 666 /etc/passwd

# Handy env var configs and subcommander env vars
ENV \
  DAB="/opt/dab" \
  PS1="\[\e[33m\]\A\[\e[m\] @ \[\e[36m\]\h\[\e[m\] \[\e[35m\]\\$\[\e[m\] " \
  PATH="$PATH:/opt/dab/bin" \
  APPLICATION="dab" \
  SUBCOMMANDS="/opt/dab/subcommands" \
  HOOK="/opt/dab/bin/pre-hook" \
  DESCRIPTION="The Developer Laboratory (Dab) is a flexible tool for managing multiple interdependent projects and their orchestration/execution, all while providing a friendly user experience and handy devops tools."

# Move just the app directory from the dab repository (along with some other
# file from previous layers) and execute from there to keep paths consistent
# and predictable.
COPY --from=prep \
  /usr/bin/subcommander \
  /usr/bin/shellcheck \
  /usr/bin/dab-completion \
  /usr/bin/ishmael \
  /usr/bin/docker-compose-gen \
  /usr/bin/kubectl \
  /usr/bin/envsubst \
  /usr/bin/helm \
  /usr/bin/
COPY --from=versioning /VERSION /LOG /

WORKDIR /opt/dab
COPY ./app ./README.md ./LICENSE ./dab ./

ENTRYPOINT ["/opt/dab/bin/dab"]

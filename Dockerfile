# Selected alpine for a small base image that many other images also use
# maximizing docker cache utilization.
FROM alpine:latest

# Docker and docker-compose are always required but take a while to install so
# they are to be kept at a lower layer for caching.
RUN apk add --no-cache docker python3 \
 && pip3 install docker-compose

# Misc tools required for scripts.
RUN apk add --no-cache git openssh tree util-linux

# Some handy defaults.
ENV PS1='\[\e[33m\]\A\[\e[m\] @ \[\e[36m\]\h\[\e[m\] \[\e[35m\]\\$\[\e[m\] '
ENV COMPOSE_PROJECT_NAME=dab

# Inside the dab container, user configurable paths are mounted to consistent
# locations.
ENV DAB_REPO_PATH="/var/dab/repos"
ENV DAB_CONF_PATH="/etc/dab"
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

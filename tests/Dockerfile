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
COPY ./Gemfile* ./
# error if Gemfile has been modified since Gemfile.lock was last updated.
RUN bundle config --global frozen 1 \
 && bundle install

COPY ./features ./features

# Check to ensure feature files are well formatted.
RUN cucumber_lint

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

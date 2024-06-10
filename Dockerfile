# syntax = docker/dockerfile:1
ARG BUNDLE_PATH=/bundler
ARG PACKAGES_RUNTIME="curl libsqlite3-0 libvips"
ARG RUBY_VERSION=3.2.3
ARG RUBY_BASE_IMAGE=registry.docker.com/library/ruby:${RUBY_VERSION}-slim
################################################################################
# Base configuration
#
FROM ${RUBY_BASE_IMAGE} AS builder-base

ARG BUNDLE_PATH
ARG PACKAGES_BUILD="build-essential git libvips pkg-config"

ENV BUNDLE_PATH=$BUNDLE_PATH
ENV BUNDLE_BIN="$BUNDLE_PATH/bin"
ENV PATH="$BUNDLE_BIN:$PATH"

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends $PACKAGES_BUILD && \
  apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Gemfile Gemfile.lock /app/
RUN gem install bundler --no-document -v $(grep -A1 'BUNDLED WITH' Gemfile.lock | tail -1 | xargs)

################################################################################
# Production builder stage
#
FROM builder-base AS builder-production

ENV BUNDLE_DEPLOYMENT=1
ENV BUNDLE_WITHOUT='development:test'
ENV RAILS_ENV=production

RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

COPY . /app/

RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

################################################################################
# Production image
#
FROM ${RUBY_BASE_IMAGE} AS production
ARG BUNDLE_PATH
ARG PACKAGES_RUNTIME

WORKDIR /app
ENV BUNDLE_DEPLOYMENT=1
ENV BUNDLE_PATH=$BUNDLE_PATH
ENV BUNDLE_BIN="$BUNDLE_PATH/bin"
ENV BUNDLE_WITHOUT='development:test'
ENV PATH="$BUNDLE_BIN:$PATH"
ENV RAILS_ENV=production

RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends $PACKAGES_RUNTIME && \
  apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Coping the generated artifacts and scrapping all the libs and binaries not necesary for execution
COPY --from=builder-production $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder-production /app /app

RUN gem install bundler --no-document -v $(grep -A1 'BUNDLED WITH' Gemfile.lock | tail -1 | xargs)

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
  chown -R rails:rails db log storage tmp
USER rails:rails

################################################################################
# Development image
#
FROM builder-base AS development
ARG GEMS_DEV="pessimizer"
ARG PACKAGES_DEV="zsh curl wget sudo"
ARG PACKAGES_RUNTIME
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID


RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends $PACKAGES_DEV $PACKAGES_RUNTIME && \
  apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  gem install $GEMS_DEV && \
  addgroup --gid $USER_GID $USERNAME && \
  adduser --home /home/$USERNAME --shell /bin/zsh --uid $USER_UID --gid $USER_GID $USERNAME && \
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
  mkdir -p $BUNDLE_PATH && \
  chown -R $USERNAME:$USERNAME $BUNDLE_PATH && \
  chown -R $USERNAME:$USERNAME /app

USER $USERNAME

RUN bundle install --jobs 4 --retry 3

WORKDIR /home/$USERNAME

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"

WORKDIR /app

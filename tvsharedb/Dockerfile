FROM ruby:3.2.0-alpine

# Install build dependencies and Node.js

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    git \
    nodejs \
    npm \
    yarn \
    tzdata \
    vips-dev \
    imagemagick \
    shared-mime-info \
    libc6-compat \
    yaml-dev \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    readline-dev \
    linux-headers \
    libpq \
    bash \
    less

# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl \
#     libjemalloc2 \
#     libvips \
#     libpq-dev \
#     build-essential \
#     curl \
#     git \
#     pkg-config \
#     libyaml-dev
    # postgresql-dev \
    # git \
#     nodejs \
#     yarn \
#     tzdata \
#     yaml-dev

# Create app directory
WORKDIR /app

ENV RAILS_ENV="development"

# Install bundler
RUN gem install bundler -v 2.4.12

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy package.json and yarn.lock if they exist
# COPY package.json yarn.lock ./
# RUN yarn install

# Copy the rest of the application
COPY . .

# Set correct permissions for the entry script
RUN chmod +x /app/bin/entry

ENTRYPOINT ["/app/bin/entry"]

# Create necessary directories
# RUN mkdir -p tmp/pids tmp/cache

# Set up database.yml explicitly
# RUN bundle exec rails db:prepare || true

# Precompile assets with explicit environment
# RUN RAILS_ENV=development SECRET_KEY_BASE=dummy \
#     bundle exec rails webpacker:compile

# Command to run the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] 
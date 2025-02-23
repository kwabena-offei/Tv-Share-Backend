FROM ruby:2.7.8-bullseye

# Install build dependencies and Node.js
# Install Node.js 16.20.2
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@8.19.4 \
    && node --version | grep -q "v16.20.2"


# Install dependencies
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        libvips \
        # nodejs \
    && npm install -g yarn \
    && apt-get clean

# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y \
#     build-essential \
#     postgresql-client \
#     postgresql-server-dev-all \
#     git \
#     nodejs \
#     npm \
#     tzdata \
#     libvips-dev \
#     imagemagick \
#     shared-mime-info \
#     libc6 \
#     libyaml-dev \
#     zlib1g-dev \
#     libxml2-dev \
#     libxslt1-dev \
#     libreadline-dev \
#     linux-headers-amd64 \
#     libpq-dev \
#     bash \
#     less && \
#     rm -rf /var/lib/apt/lists/* && \
#     npm install -g yarn

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

ENV RAILS_ENV="production"

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
FROM ruby:2.7.8-bullseye

# Install build dependencies and Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@8.19.4 yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install additional dependencies
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        libpq-dev \
        libvips \
        git \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Set production environment
ENV RAILS_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true" \
    NODE_ENV="production"

# Install bundler
RUN gem install bundler -v 2.4.12

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install --jobs=4 --retry=3

# Copy package.json and yarn.lock for JavaScript dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# Copy the rest of the application
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log \
    && chmod +x /app/bin/entry

# Expose port (Heroku sets PORT env variable)
EXPOSE 3000

# Use entry script for initialization
ENTRYPOINT ["/app/bin/entry"]

# Default command 
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"] 
FROM ruby:3.2.2-alpine

# Install dependencies
RUN apk add --no-cache \
    postgresql-dev \
    build-base \
    tzdata \
    nodejs \
    yarn

WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Precompile assets (if needed)
# RUN bundle exec rake assets:precompile

EXPOSE 3000

# Start the server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

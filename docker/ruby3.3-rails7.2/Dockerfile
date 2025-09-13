FROM ruby:3.3

# Pin RubyGems version
ENV RUBYGEMS_VERSION=3.5.6

RUN gem update --system $RUBYGEMS_VERSION && \
    gem install bundler -v 2.4.22

WORKDIR /app

# Copy and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle _2.4.22_ install --jobs 4

COPY . .

ENTRYPOINT ["docker/entrypoint"]

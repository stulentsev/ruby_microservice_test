######################
# Stage: ruby
FROM ruby:2.6.1-alpine3.9 as ruby
LABEL description="Base ruby image used by other stages"
LABEL maintainer="Nikolai Vladimirov <nikolay@vladimiroff.com>"

######################
# Stage: bundler
FROM ruby as bundler
LABEL description="Install and cache gems for all environments"

WORKDIR /home/app/services/driver_location

# Copy the Gemfile and Gemfile.lock
COPY Gemfile* /home/app/services/driver_location/

# Install build deps and gems from all environments under vendor/bundle path
RUN apk add --update --no-cache --virtual .build-deps \
    build-base \
 && bundle install --frozen --deployment --jobs 4 --retry 3 \
 # Remove unneeded files (*/.git, *.o, *.c) but keeps cached gems for later stages
 && find vendor/bundle/ -name ".git" -exec rm -rv {} + \
 && find vendor/bundle/ -name "*.c" -delete \
 && find vendor/bundle/ -name "*.o" -delete \
 # Remove unneeded build deps
 && apk del .build-deps

###############################
# Stage runner
FROM ruby as runner
LABEL description="Builds an image ready to be run"

 RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app \
 && mkdir -p /home/app/services/driver_location \
 && chown -R app:app /home/app/services/driver_location

USER app
WORKDIR /home/app/services/driver_location

# Copy bundle config from bundler stage
COPY --chown=app:app --from=bundler /usr/local/bundle/config /usr/local/bundle/config
# Copy bundled gems from bundler stage
COPY --chown=app:app --from=bundler /home/app/services/driver_location/vendor /home/app/services/driver_location/vendor
# Copy source files according to .dockerignore policy
# Make sure your .dockerignore file is properly configure to ensure proper layer caching
COPY --chown=app:app . /home/app/services/driver_location

ENTRYPOINT ["bundle", "exec"]


###############################
# Stage release
FROM runner as dev
LABEL description="Builds an image ready to be run with changes for dev env"

ENV PORT 3000

# Expose web server port
EXPOSE 3000

CMD ["puma", "-C", "config/puma.rb"]

###############################
# Stage release
FROM runner as release
LABEL description="Builds a release image removing unneeded files and dependencies"

# Removes development and test gems by re-running the bundle install command
# using cached gems and simply removing unneeded gems using the clean option.
RUN bundle install --local --clean --without development test \
 # Remove unneeded cached gems
 && find vendor/bundle/ -name "*.gem" -delete \
 # Remove unneeded files and folders
 && rm -rf spec tmp/cache

ARG ENV=production

# Set App env variables
ENV RACK_ENV $ENV

###############################
# Stage web
FROM release as web
LABEL description="Builds a production ready image specific to web"

ENV PORT 3000

# Expose web server port
EXPOSE 3000

CMD ["puma", "-C", "config/puma.rb"]

###############################
# Stage web
FROM release as consumer

LABEL description="Builds a production ready image specific to the message consumer"
CMD ["bin/consumer", "start"]

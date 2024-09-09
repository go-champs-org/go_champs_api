ARG EX_VERSION=latest
FROM elixir:${EX_VERSION}

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get install -y git && \
    mix local.hex --force && \
    mix local.rebar --force

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

EXPOSE 4000
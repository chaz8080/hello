FROM elixir:1.8.1 AS base

# Install NodeJS: https://github.com/nodesource/distributions/blob/master/README.md#debinstall
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - \
 && apt-get install -y nodejs

# Install yarn: 
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install yarn

# Install hex, rebar, and phoenix
RUN mix local.hex --force \
 && mix local.rebar --force \
 && mix archive.install hex --force phx_new 1.4.0

FROM base AS build

WORKDIR /app

COPY . /app

RUN rm -rf /app/deps \
 && rm -rf /app/_build \
 && rm -rf /app/assets/node_modules \
 && mix do deps.get, compile \
 && cd assets \
 && npm install \
 && ./node_modules/webpack/bin/webpack.js --mode production \
 && cd .. \
 && mix phx.digest \
 && MIX_ENV=prod mix release --env=prod 

FROM elixir:1.8.1

COPY --from=build /app/_build/prod/rel/hello /app/hello

CMD PORT=${PORT} /app/hello/bin/hello foreground
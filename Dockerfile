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

FROM base

# User should volume their app onto the WORKDIR: /usr/app
WORKDIR /app

CMD rm -rf deps \
 && rm -rf _build \
 && rm -rf assets/node_modules \
 && mix do deps.get, compile \
#  && mix compile \
## If there is no rel/config.exs file, call release.init function
 && [ -f ./rel/config.exs ] || mix release.init \ 
 && cd assets \
 && npm install \
 && ./node_modules/webpack/bin/webpack.js --mode production \
 && cd .. \
 && mix phx.digest \
 && MIX_ENV=prod mix release --env=prod \
 && tail -f /dev/null

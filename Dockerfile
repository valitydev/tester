FROM docker.io/library/elixir:1.14-otp-24 AS builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy sources
RUN mkdir /build
COPY . /build/

# Build the release
WORKDIR /build
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    MIX_ENV=prod mix release

FROM docker.io/library/elixir:1.14-otp-24-slim

# Set env
ENV CHARSET=UTF-8
ENV LANG=C.UTF-8


# Set runtime
WORKDIR /opt/tester

COPY --from=builder /build/_build/prod/rel/tester /opt/tester

WORKDIR /opt/tester
CMD /opt/tester/bin/tester start
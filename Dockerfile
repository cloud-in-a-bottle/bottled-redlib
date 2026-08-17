# OpenHost Redlib container.
#
# Builds the redlib binary from upstream source in a multi-
# stage Rust build, then ships just the binary on a slim
# Ubuntu runtime.  We do NOT use the prebuilt
# quay.io/redlib/redlib image because of redlib-org/redlib#551
# (May 2026): the published image's binary fails to obtain an
# OAuth token from Reddit ("Failed to create OAuth client:
# expected value at line 1 column 1", "401 Unauthorized"),
# but building the same commit from source via Dockerfile.ubuntu
# works correctly.  Multiple users confirmed this workaround
# on the issue thread.
#
# This Dockerfile mirrors the structure of upstream's
# Dockerfile.ubuntu, adapted to clone redlib at a pinned
# commit so OUR build is reproducible across deploys.  Bump
# the REDLIB_COMMIT line below to upgrade.
#
# No persistent state, no auth-proxy: the OpenHost router
# passes anonymous traffic through (public_paths = ["/"]),
# and redlib stores user prefs as URL query strings on the
# client.

########################
## builder image
########################
FROM docker.io/library/rust:slim-bookworm AS builder

# Build deps.  cmake + libclang-dev are needed by some of
# redlib's transitive dependencies; build-essential pulls in
# gcc.  git is needed to clone the source.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git \
        build-essential \
        cmake \
        libclang-dev \
        ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Pin to a specific upstream commit for reproducible builds.
# Bump this to track newer upstream changes.  This is the
# 2026-04-24 commit a4d36e9 (== upstream release v0.36.0).
ARG REDLIB_COMMIT=a4d36e954cf1bd64f209cd8868c5a29edc81b374
RUN git clone https://github.com/redlib-org/redlib.git redlib \
 && cd redlib \
 && git checkout "$REDLIB_COMMIT" \
 && cargo build --release --locked --bin redlib

########################
## release image
########################
FROM docker.io/library/ubuntu:noble

# Runtime deps:
#   * ca-certificates — for HTTPS to reddit.com.
#   * wget            — for the health probe.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean

# Lift just the binary from the builder.
COPY --from=builder /build/redlib/target/release/redlib /usr/local/bin/redlib

# Non-root user.  Redlib doesn't need root for anything — it's
# a stateless network app.
RUN useradd \
    --no-create-home \
    --password "!" \
    --comment "user for running redlib" \
    redlib
USER redlib

# Redlib binds 0.0.0.0:8080 by default.
EXPOSE 8080

# Enable RSS feeds (/r/<sub>.rss, /user/<u>.rss, etc.).  Redlib only serves
# RSS when REDLIB_ENABLE_RSS is set; when it is unset every .rss path returns
# a 404 "RSS is disabled on this instance." page.  Baked into the image
# because OpenHost's manifest has no [runtime.container].env passthrough.
ENV REDLIB_ENABLE_RSS=on

CMD ["redlib"]

# Bottled Redlib container.
#
# Runs Nachtalb's Redlib fork (https://github.com/Nachtalb/redlib)
# from its published image, pinned by digest.  Upstream
# redlib-org/redlib no longer works against Reddit: as of
# 2026-10-30 every page, on v0.36.0 and on v0.40.0 alike, fails
# with "Failed to parse page JSON data: expected value at line 1
# column 1".  The fork fetches through Reddit's GraphQL API and
# the website's anonymous token_v2 instead, and the public
# instances that still work run it.  It is patched far more
# often than upstream, so check its commits when Reddit breaks
# things again.
#
# The fork publishes a ready-built image (a static musl binary
# on distroless, ~16 MB), so there is no Rust build here; the
# upstream-image bug that made us build from source before
# (redlib-org/redlib#551) does not apply to this build.
#
# To upgrade, pick a newer `sha-<commit>` tag from
# https://github.com/Nachtalb/redlib/pkgs/container/redlib,
# update the tag and the index digest below, and update the
# commit in NOTICE.
FROM ghcr.io/nachtalb/redlib:sha-809a793@sha256:374e4effb9d66d8d7909277dbc2cbafd621f4ba301838fef3474d3d46b36c8c9

# The image runs `redlib` as uid 65532 and binds 0.0.0.0:8080.
# It has no shell or wget; the router probes /settings over HTTP.

# Enable RSS feeds (/r/<sub>.rss, /user/<u>.rss, etc.).  Redlib only serves
# RSS when REDLIB_ENABLE_RSS=on; otherwise those paths say
# "RSS is disabled on this instance."
ENV REDLIB_ENABLE_RSS=on

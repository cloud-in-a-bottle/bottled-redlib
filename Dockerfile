# OpenHost Redlib container.
#
# Minimal wrapper around the upstream redlib image.  Redlib is
# a single statically-linked Rust binary with no runtime
# dependencies and no persistent state, so the "wrapper" here
# is really just the upstream image with the openhost.toml
# manifest committed alongside it.
#
# No auth-proxy sidecar: Redlib is meant to be publicly
# browsable (it's a Reddit mirror), and the OpenHost router
# passes traffic through when public_paths = ["/"] in
# openhost.toml.
#
# No persistent volume: Redlib is stateless.  User
# preferences (theme, layout, NSFW filter, etc.) are kept as
# URL query strings on the client.

# Pin to a specific version tag rather than `latest` so a
# redeploy can't silently pull a different upstream build.
# Bump this line to upgrade.  v0.36.0 is current as of
# packaging time (Apr 2026).
FROM quay.io/redlib/redlib:v0.36.0

# Upstream EXPOSE'd 8080 and CMD'd "redlib"; we inherit both.
#
# Defaults the upstream image already sets that we deliberately
# keep:
#   * USER redlib       (drops root)
#   * CMD ["redlib"]    (binds 0.0.0.0:8080 by default)
#   * HEALTHCHECK ...   (we have routing.health_check too)

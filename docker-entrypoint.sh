#!/bin/sh
set -e

# radvd requires the directory for its pid file to exist.
# /run is often a tmpfs, so we need to create this at runtime, not build time.
mkdir -p /run/radvd

# exec the passed command (e.g. radvd -n -m stderr)
exec "$@"

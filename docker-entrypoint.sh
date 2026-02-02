#!/bin/sh
set -e

# radvd requires the directory for its pid file to exist.
# /run is often a tmpfs, so we need to create this at runtime, not build time.
mkdir -p /run/radvd

# Check if the command is radvd and DEBUG is set
if [ "$1" = "radvd" ] && [ "$DEBUG" = "1" ]; then
    # Enable full debugging (level 5)
    set -- "$@" -d 5
fi

# exec the passed command (e.g. radvd -n -m stderr)
exec "$@"

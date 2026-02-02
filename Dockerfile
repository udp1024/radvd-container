FROM alpine:3.23

# Install radvd
RUN apk add --no-cache radvd

# Ensure the directory for the pid file exists (handled by apk usually, but good to be safe)
# radvd defaults: config /etc/radvd.conf, pid /var/run/radvd.pid
# We will run in foreground, so PID file might matter less, but keeping standard paths.

# Copy default config
COPY radvd.conf /etc/radvd.conf

# Run radvd in foreground (-n) and log to stderr (-m stderr) so Docker can capture logs
CMD ["radvd", "-n", "-m", "stderr"]

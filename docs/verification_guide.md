# Radvd Container Verification Guide

This guide provides step-by-step instructions to verify the deployment of the `radvd-alpine` container from both GitHub Container Registry (GHCR) and Docker Hub.

## Prerequisites

- Docker installed and running.
- `jq` (optional, for JSON output parsing).

## 1. Verify Docker Hub Image

**Goal**: Pull the image from Docker Hub and run it with the default configuration.

```bash
# 1. Pull the image
docker pull udp1024/radvd-alpine:2.20

# 2. Run the container (Foreground mode to see logs)
# We use --net=host and caps, but for a simple version check or config check, we can omit them if just checking binary presence.
# However, to test full startup:
docker run --rm --name radvd-hub \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  udp1024/radvd-alpine:2.20

# EXPECTED OUTPUT:
# [date] radvd (1): version 2.20 started
# [date] radvd (1): config file, /etc/radvd.conf, syntax ok
# ... (logs indicating it's ready)
# Press Ctrl+C to stop.
```

## 2. Verify GHCR Image

**Goal**: Pull the image from GitHub Container Registry.

```bash
# 1. Pull the image
docker pull ghcr.io/udp1024/radvd-container:2.20

# 2. Run the container
docker run --rm --name radvd-ghcr \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  ghcr.io/udp1024/radvd-container:2.20

# EXPECTED OUTPUT:
# Same as above.
```

## 3. Verify Custom Configuration

**Goal**: Ensure we can mount a custom config file.

```bash
# 1. Create a test config
cat <<EOF > test_radvd.conf
interface lo {
    AdvSendAdvert off;
    prefix 2001:db8:test::/64 {
        AdvOnLink off;
        AdvAutonomous off;
    };
};
EOF

# 2. Run with mounted config using the Docker Hub image
docker run --rm \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -v $(pwd)/test_radvd.conf:/etc/radvd.conf \
  udp1024/radvd-alpine:2.20 \
  radvd -c -d 1

# EXPECTED OUTPUT:
# [date] radvd (1): config file, /etc/radvd.conf, syntax ok
```

## 4. Verify Architecture (Optional)

If you have an `arm64` device (like a Raspberry Pi or Apple Silicon Mac), running the above commands will automatically pull the `arm64` variant. You can inspect the image to see supported architectures:

```bash
docker manifest inspect udp1024/radvd-alpine:2.20
```

**Expected Output**: JSON showing platforms `linux/amd64` and `linux/arm64`.

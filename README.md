# radvd-container

Containerized IPv6 ULA Router Advertisement for Stable Internal Networking

radvd-container provides a minimal, containerized way to advertise IPv6 Unique Local Address (ULA) prefixes on local networks using Router Advertisements (RA).

It is designed for environments where ISPs delegate unstable IPv6 prefixes, making it impossible to rely on predictable global IPv6 addresses for internal services.

This container restores stable IPv6 addressing for home labs, self‑hosting, and internal infrastructure—without depending on ISP behavior, router firmware features, or deprecated Linux mechanisms.

🌐 Project website: <https://neuraldesigns.ca/radvd-container>

## Why This Exists

Many consumer ISPs delegate a single IPv6 /64 prefix that changes unpredictably. Linux previously allowed stable interface identifiers using the token keyword, but that feature has been removed.

## The result

* Internal IPv6 addresses change unexpectedly
* Self‑hosted services break
* DNS records become unreliable
* IPv6 becomes impractical for internal infrastructure

This project exists to solve that problem.

By advertising a locally scoped IPv6 ULA prefix (fc00::/7) using radvd, internal devices gain stable, predictable IPv6 addresses that do not depend on ISP prefix delegation.

Running radvd as a container keeps the solution:

* Portable
* Auditable
* Independent of router firmware
* Easy to deploy on any Linux host

## What This Container Does

* Advertises an IPv6 ULA prefix as on‑link
* Uses Router Advertisements (SLAAC) for client discovery
* Does not advertise a default route
* Does not interfere with ISP‑provided global IPv6 routing
* Runs as a minimal Alpine‑based container

This allows internal services to bind to static IPv6 addresses while remaining fully isolated from ISP prefix churn.

## Typical Use Cases

* Home lab IPv6 networking
* Self‑hosted services requiring stable IPv6 addresses
* Internal APIs and monitoring endpoints
* IPv6‑only internal networks
* Router firmware lacking proper RA customization
* Environments where DHCPv6 is undesirable

## Architecture Overview

* ISP provides a dynamic global IPv6 prefix
* Internal network uses a static ULA prefix
* radvd-container advertises the ULA prefix only
* Clients auto‑configure ULA addresses via SLAAC
* Internal services bind to stable IPv6 addresses

This separation restores IPv6 usability without NAT or DHCPv6.

![Architecture](https://neuraldesigns.ca/graphics/radvd-container.svg)

## Container Image

Available on Docker Hub and GitHub Container Registry:

```docker pull udp1024/radvd-alpine:edge```

## Configuration

A minimal radvd.conf is required to advertise the ULA prefix.

You can:

Review example configurations in the documentation
Generate a baseline configuration using the included setup script
Documentation and examples: <https://github.com/udp1024/radvd-container>

## Design Principles

* Explicit configuration
* Minimal surface area
* No hidden routing behavior
* Infrastructure‑as‑code friendly
* Designed for long‑term IPv6 stability

## Related Resources

Project website: <https://neuraldesigns.ca/radvd-container>

GitHub repository: <https://github.com/udp1024/radvd-container>

Docker image: udp1024/radvd-alpine

## License

MIT License

## Versions

* **Project Version**: 2.20
* **OS**: Alpine Linux 3.23
* **Software**: radvd 2.20-r0

## Usage

### Basic Run

**Docker Hub:**

```bash
docker run --name radvd \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  udp1024/radvd-alpine:latest
```

**GitHub Container Registry:**

```bash
docker pull ghcr.io/udp1024/radvd-container:latest
docker run --name radvd \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  ghcr.io/udp1024/radvd-container:latest
```

*Note: `--net=host`, `--cap-add=NET_ADMIN` and `--cap-add=NET_RAW` are required. Radvd needs to run as root on the host network interface to open raw sockets for sending ICMPv6 router advertisements.*

### Configuration

The container comes with a non-invasive, passive default configuration located at `/etc/radvd.conf`. The config is liberally commented to document settings.

To use your own configuration, mount a custom `radvd.conf` file to `/etc/radvd.conf`:

```bash
docker run -d \
  --name radvd \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -v $(pwd)/radvd.conf:/etc/radvd.conf \
  udp1024/radvd-alpine:latest
```

## Debugging

If you encounter issues, you can enable verbose logging by setting the `DEBUG` environment variable to `1`. This will launch `radvd` with the `-d 5` flag.

```bash
docker run -d \
  --name radvd \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -e DEBUG=1 \
  udp1024/radvd-alpine:edge
```

## Contributing

This project is configured to automatically build and publish images to GHCR and Docker Hub on new releases.

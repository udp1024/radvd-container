# Radvd Container

A lightweight Docker container for `radvd` (Router Advertisement Daemon) based on **Alpine Linux 3.23**.

This container provides a IPv6 Router Advertisement Daemon to advertise IPv6 prefixes and routes to the local network.

## Versions

- **Project Version**: 2.20
- **OS**: Alpine Linux 3.23
- **Software**: radvd 2.20-r0

## Usage

### basic Run

```bash
docker run --name radvd --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW radvd-container
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
  -v $(pwd)/my-radvd.conf:/etc/radvd.conf \
  radvd-container
```

## Contributing

This project is configured to automatically build and publish images to GHCR and Docker Hub on new releases.

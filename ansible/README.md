# Ansible Infrastructure Automation

![Ansible](https://img.shields.io/badge/Ansible-EE0000.svg?style=for-the-badge&logo=ansible&logoColor=white)
![Infrastructure](https://img.shields.io/badge/Infrastructure-as%20Code-blue.svg?style=for-the-badge)

This directory contains Ansible playbooks and roles for automated infrastructure management and service deployment. The automation provides idempotent deployment and management of various services across multiple hosts, currently featuring a comprehensive monitoring stack based on Prometheus exporters.

## Philosophy

This Ansible configuration follows the **declarative infrastructure as code** principles, ensuring:

- **Idempotent Operations:** Roles can be run multiple times safely without causing unintended changes.
- **Secure Deployment:** Automated checksum verification and proper service isolation with dedicated system users.
- **Flexible Configuration:** Support for multiple architectures and configurable parameters through variables.
- **Scalable Design:** Modular role-based architecture that facilitates easy addition of new services and components.

## Table of Contents

- [Available Services](#available-services)
- [Quick Start](#quick-start)
- [Service Details](#service-details)
  - [Node Exporter](#node-exporter)
  - [Blackbox Exporter](#blackbox-exporter)
  - [Proxmox VE Exporter](#proxmox-ve-exporter)
- [Management Operations](#management-operations)
- [Configuration](#configuration)
- [Architecture Support](#architecture-support)

## Available Services

### Monitoring Stack

| Service | Purpose | Default Port | Status |
|----------|---------|--------------|--------|
| **Node Exporter** | System metrics (CPU, memory, disk, network) | 9100 | ✅ Active |
| **Blackbox Exporter** | Network probing (HTTP, HTTPS, DNS, TCP, ICMP) | 9115 | ✅ Active |
| **Proxmox VE Exporter** | Proxmox Virtual Environment metrics | 9221 | ✅ Active |

## Quick Start

All commands are executed via the `Justfile` interface for consistency and ease of use.

### Deploy Node Exporter
```bash
# Deploy to single host
just node_exporter 192.168.1.10

# Deploy to multiple hosts
just node_exporter "192.168.1.10,192.168.1.11,192.168.1.12"

# Custom configuration
just node_exporter 192.168.1.10 USER=admin PORT=2222 VERSION=v1.9.1
```

### Deploy Blackbox Exporter
```bash
# Deploy to single host
just blackbox_exporter 192.168.1.10

# Deploy with custom configuration
just blackbox_exporter 192.168.1.10 VERSION=v0.27.0 LISTEN=":9115"
```

### Deploy Proxmox VE Exporter
```bash
# Deploy with API token
just pve_exporter 192.168.1.100 TOKEN=your-api-token USER=root
```

## Service Details

### Node Exporter

**Purpose:** Collects hardware and OS metrics from Unix-based systems.

**Key Features:**
- Multi-architecture support (amd64, arm64, armv7, armv6, 386, ppc64le, s390x, riscv64)
- Automatic latest version resolution from GitHub releases
- Systemd integration with proper service isolation
- Configurable collectors via flags

**Default Configuration:**
- Version: `v1.9.1`
- Listen Address: `:9100`
- Default Flags: `--collector.systemd`
- Service User: `node_exporter` (system user, no shell)

### Blackbox Exporter

**Purpose:** Probes external services via HTTP, HTTPS, DNS, TCP, and ICMP.

**Key Features:**
- Configurable probing modules
- Support for custom configuration files
- SSL/TLS verification capabilities
- Multi-target monitoring

**Default Configuration:**
- Version: `v0.27.0`
- Listen Address: `:9115`
- Config Path: `/etc/blackbox.yml`

### Proxmox VE Exporter

**Purpose:** Collects metrics from Proxmox Virtual Environment clusters.

**Key Features:**
- API token-based authentication
- Virtual machine and container metrics
- Storage and network statistics
- Python-based implementation with virtual environment isolation

**Default Configuration:**
- Listen Address: `:9221`
- API URL: `https://localhost:8006`
- SSL Verification: Disabled (configurable)

## Management Operations

### Remove Services

Each service includes removal playbooks for clean uninstallation:

```bash
# Remove services
just remove_node_exporter 192.168.1.10
just remove_blackbox_exporter 192.168.1.10
just remove_pve_exporter 192.168.1.100
```

**Removal Process:**
- Stops and disables systemd services
- Removes service files and binaries
- Cleans up configuration files
- Removes dedicated system users

## Configuration

### Global Settings

The `ansible.cfg` file provides global configuration:
- **Roles Path:** `./roles`
- **Host Key Checking:** Disabled for automation
- **Python Interpreter:** Auto-detection
- **Output Format:** YAML for readability

### Variable Override

All services support runtime variable override via the `-e` flag:

```bash
# Override default listen address
just node_exporter 192.168.1.10 LISTEN=":9101"

# Use latest version instead of pinned
just node_exporter 192.168.1.10 LATEST="true"

# Custom flags for collectors
just node_exporter 192.168.1.10 FLAGS="--collector.systemd --collector.processes"
```

### Common Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USER` | `rus` | SSH connection user |
| `PORT` | `22` | SSH connection port |
| `SSH_ARGS` | `""` | Additional SSH arguments |
| `LATEST` | `false` | Use latest version from GitHub |

## Architecture Support

The roles automatically detect the target architecture and download the appropriate binaries:

- **x86_64** → amd64
- **aarch64** → arm64
- **armv7l** → armv7
- **armv6l** → armv6
- **i386** → 386
- **ppc64le** → ppc64le
- **s390x** → s390x
- **riscv64** → riscv64

All downloads include **SHA256 checksum verification** for security and integrity.
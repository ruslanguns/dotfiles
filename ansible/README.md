# Ansible Automation

This directory contains Ansible playbooks and roles for automating the deployment and management of various services and tools.

## Overview

The Ansible automation in this repository is designed to deploy and manage Prometheus exporters and related services on remote hosts. It provides a simple and consistent way to set up monitoring infrastructure with minimal manual intervention.

## Structure

- `playbooks/`: Contains the main playbook files for each service.
- `roles/`: Contains the Ansible roles that define the tasks, templates, and variables for each service.
- `collections/`: Defines any required Ansible collections (currently empty).
- `ansible.cfg`: The Ansible configuration file.
- `Justfile`: Provides convenient commands for running the playbooks.

## Available Services

### Node Exporter

Deploys the Prometheus Node Exporter, which collects hardware and OS metrics from the host machine.

**Commands:**
```bash
# Deploy node exporter
just node_exporter <host-ip-or-name>

# Remove node exporter
just remove_node_exporter <host-ip-or-name>
```

### Blackbox Exporter

Deploys the Prometheus Blackbox Exporter, which allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP, and ICMP.

**Commands:**
```bash
# Deploy blackbox exporter
just blackbox_exporter <host-ip-or-name>

# Remove blackbox exporter
just remove_blackbox_exporter <host-ip-or-name>
```

### PVE Exporter

Deploys the Prometheus Proxmox VE Exporter, which collects metrics from Proxmox VE environments.

**Commands:**
```bash
# Deploy PVE exporter (requires Proxmox API token)
just pve_exporter TOKEN=<api-token> <host-ip-or-name>

# Remove PVE exporter
just remove_pve_exporter <host-ip-or-name>
```

## Usage

1. Ensure you have Ansible installed on your local machine.
2. Make sure you can SSH into the target hosts.
3. Use the provided `just` commands to deploy or remove services.

### Examples

Deploy Node Exporter to a single host:
```bash
just node_exporter 192.168.1.100
```

Deploy Blackbox Exporter to multiple hosts:
```bash
just blackbox_exporter 192.168.1.100,192.168.1.101,192.168.1.102
```

Deploy PVE Exporter with a specific API token:
```bash
just pve_exporter TOKEN=your-api-token 192.168.1.100
```

## Customization

Each role has default variables that can be overridden:

- Node Exporter: `roles/node_exporter/defaults/main.yml`
- Blackbox Exporter: `roles/blackbox_exporter/defaults/main.yml`
- PVE Exporter: `roles/pve_exporter/defaults/main.yml`

You can also modify the service templates in the `templates/` directory of each role to customize the systemd unit files or configuration files.
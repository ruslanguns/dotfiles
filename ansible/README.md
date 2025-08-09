# Ansible Playbooks

This directory automates the deployment of monitoring exporters and related tooling with [Ansible](https://www.ansible.com/).

## Table of Contents

- [Structure](#structure)
- [Usage](#usage)
  - [Deploy exporters](#deploy-exporters)
  - [Remove exporters](#remove-exporters)

## Structure

- `ansible.cfg`: Local Ansible settings and role paths.
- `Justfile`: Wrapper commands around `ansible-playbook`.
- `playbooks/`: Playbooks to install or remove exporters.
- `roles/`: Role implementations for each exporter.
- `collections/`: Vendored Ansible collections.

## Usage

### Deploy exporters

Run the Just recipes with a comma-separated list of hosts:

```bash
# Install node_exporter on two machines
just node_exporter HOSTS=host1,host2 USER=rus

# Install pve_exporter (requires an API token)
just pve_exporter HOSTS=pve1 TOKEN=token USER=root

# Install blackbox_exporter with a custom config path
just blackbox_exporter HOSTS=host1 CONFIG=/etc/blackbox.yml
```

### Remove exporters

```bash
# Remove node_exporter
just remove_node_exporter HOSTS=host1 USER=rus

# Remove pve_exporter
just remove_pve_exporter HOSTS=pve1 USER=root

# Remove blackbox_exporter
just remove_blackbox_exporter HOSTS=host1 USER=rus
```

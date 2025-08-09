# Ansible Configuration

![Ansible](https://img.shields.io/badge/Ansible-2.12%2B-red?style=for-the-badge&logo=ansible)
![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)

This directory contains Ansible playbooks and roles designed to configure services and applications on non-NixOS machines.

## Philosophy

The goal of this configuration is to provide a simple, idempotent, and reusable way to deploy common applications and services. While the main repository focuses on declarative management with Nix, this section offers a more traditional Ansible-based approach for systems where Nix is not available. A `Justfile` acts as a friendly wrapper, simplifying the execution of playbooks.

## Table of Contents

- [Directory Structure](#directory-structure)
- [Usage](#usage)
  - [Example: Node Exporter](#example-node-exporter)
  - [Example: PVE Exporter](#example-pve-exporter)
  - [Example: Blackbox Exporter](#example-blackbox-exporter)
- [Available Roles](#available-roles)
  - [blackbox_exporter](#blackbox_exporter)
  - [node_exporter](#node_exporter)
  - [pve_exporter](#pve_exporter)
- [Adding a New Role](#adding-a-new-role)

## Directory Structure

- `Justfile`: The main command runner for deploying and removing components. This is the intended entry point for all operations.
- `ansible.cfg`: Basic Ansible configuration file.
- `playbooks/`: Contains the main playbooks for installing or removing each component.
- `roles/`: Contains the core logic for each component, including tasks, templates, and default variables.

## Usage

All tasks are executed via the `Justfile` located in this directory. The primary argument is `HOSTS`, which should be a comma-separated list of SSH targets (e.g., `user@host1,user@host2`).

The following examples demonstrate how to deploy the currently available roles.

### Example: Node Exporter

Deploys `node_exporter` to expose system-level metrics.

- **Deploy:**

  ```bash
  # Usage: just node_exporter HOSTS="<user@ip>" [USER="rus"] [VERSION="v1.9.1"]
  just node_exporter HOSTS="192.168.1.10"

  # Usage targeting  multiple hosts
  just node_exporter HOSTS="px1,px2,px3"
  ```

- **Remove:**
  ```bash
  # Usage: just remove_node_exporter HOSTS="<user@ip>"
  just remove_node_exporter HOSTS="rus@192.168.1.10"
  #  Usage targeting multiple hosts
  just remove_node_exporter HOSTS="px1,px2,px3"
  ```

### Example: PVE Exporter

Deploys `prometheus-pve-exporter` to expose Proxmox VE metrics.

- **Deploy:**

  ```bash
  # Usage: just pve_exporter HOSTS="<user@ip>" TOKEN="<api-token>" [API_URL="<url>"]
  just pve_exporter HOSTS="root@pve-"host" TOKEN="my-secret-pve-token"
  # Usage targeting multiple hosts
  just pve_exporter HOSTS="px1,px2,px3"
  ```

- **Remove:**
  ```bash
  # Usage: just remove_pve_exporter HOSTS="<user@ip>"
  just remove_pve_exporter HOSTS="root@pve-host"
  # Usage targeting multiple hosts
  just remove_pve_exporter HOSTS="px1,px2,px3"
  ```

### Example: Blackbox Exporter

Deploys `blackbox_exporter` for black-box probing of endpoints.

- **Deploy:**

  ```bash
  # Usage: just blackbox_exporter HOSTS="<user@ip>" [VERSION="v0.27.0"]
  just blackbox_exporter HOSTS="rus@192.168.1.20"
  # Usage targeting multiple hosts
  just blackbox_exporter HOSTS="px1,px2,px3"
  ```

- **Remove:**
  ```bash
  # Usage: just remove_blackbox_exporter HOSTS="<user@ip>"
  just remove_blackbox_exporter HOSTS="rus@192.168.1.20"
  # Usage targeting multiple hosts
  just remove_blackbox_exporter HOSTS="px1,px2,px3"
  ```

## Available Roles

The following roles are defined in this project. Their behavior can be customized by passing variables via the `just` command using the `-e "variable=value"` syntax with `ansible-playbook`.

### `blackbox_exporter`

Installs and configures the Prometheus Blackbox Exporter.

| Variable                        | Default Value             | Description                                         |
| :------------------------------ | :------------------------ | :-------------------------------------------------- |
| `blackbox_exporter_version`     | `"v0.27.0"`               | The version to install.                             |
| `blackbox_exporter_latest`      | `false`                   | If `true`, fetches the latest version from GitHub.  |
| `blackbox_exporter_listen`      | `":9115"`                 | The address and port for the exporter to listen on. |
| `blackbox_exporter_config_path` | `"/etc/blackbox.yml"`     | Path to the configuration file on the target host.  |
| `blackbox_exporter_flags`       | `"--config.file={{...}}"` | Extra command-line flags for the service.           |

### `node_exporter`

Installs and configures the Prometheus Node Exporter.

| Variable                | Default Value | Description                                         |
| :---------------------- | :------------ | :-------------------------------------------------- |
| `node_exporter_version` | `"v1.9.1"`    | The version to install.                             |
| `node_exporter_latest`  | `false`       | If `true`, fetches the latest version from GitHub.  |
| `node_exporter_listen`  | `":9100"`     | The address and port for the exporter to listen on. |
| `node_exporter_flags`   | `""`          | Extra command-line flags for the service.           |

### `pve_exporter`

Installs and configures the Prometheus PVE Exporter.

| Variable                 | Default Value              | Description                                                         |
| :----------------------- | :------------------------- | :------------------------------------------------------------------ |
| `pve_api_url`            | `"https://localhost:8006"` | The URL of the Proxmox API.                                         |
| `pve_user`               | `"root@pam"`               | The Proxmox user for the API token.                                 |
| `pve_token_name`         | `"monitoring"`             | The name of the API token.                                          |
| `pve_token_value`        | `""`                       | **Required.** The secret value of the API token.                    |
| `pve_verify_ssl`         | `false`                    | Whether to verify the SSL certificate of the Proxmox API.           |
| `pve_listen`             | `":9221"`                  | The address and port for the exporter to listen on.                 |
| `pve_disable_collectors` | `[]`                       | A list of collectors to disable (e.g., `["cluster", "resources"]`). |

## Adding a New Role

To add a new component or service, follow the existing structure:

1.  **Create the Role**: Add a new directory under `roles/` with the standard `tasks`, `templates`, `defaults`, and `handlers` subdirectories.
2.  **Create the Playbook**: Add a simple playbook in `playbooks/` that includes the new role. Create a corresponding `remove_...` playbook if needed.
3.  **Update the Justfile**: Add new recipes to the `Justfile` for deploying and removing the new component, following the existing patterns.
4.  **Update this README**: Document the new role and its usage instructions here.

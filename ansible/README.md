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
  - [Example: Prometheus](#example-prometheus)
  - [Example: Firewall](#example-firewall)
  - [Example: Smokeping Prober](#example-smokeping-prober)
- [Available Roles](#available-roles)
  - [blackbox_exporter](#blackbox_exporter)
  - [node_exporter](#node_exporter)
  - [pve_exporter](#pve_exporter)
  - [prometheus](#prometheus)
  - [firewall](#firewall)
  - [smokeping_prober](#smokeping_prober)
- [Adding a New Role](#adding-a-new-role)

## Directory Structure

- `Justfile`: The main command runner that loads functionality from submodules. This is the intended entry point for all operations.
- `install.just`: Submodule containing all deployment-related recipes.
- `remove.just`: Submodule containing all removal-related recipes.
- `configure.just`: Submodule containing all configuration-related recipes.
- `ansible.cfg`: Basic Ansible configuration file.
- `playbooks/`: Contains the main playbooks for installing or removing each component.
- `roles/`: Contains the core logic for each component, including tasks, templates, and default variables.

## Usage

All tasks are executed via the `Justfile` using a modular structure. The general syntax is:
`just <subcommand> <recipe> <HOSTS> [ARGS...]`

- **`<subcommand>`**: The action to perform: `install`, `remove`, or `configure`.
- **`<recipe>`**: The name of the component to manage (e.g., `node_exporter`).
- **`<HOSTS>`**: A single hostname or a comma-separated string of hosts (e.g., `"host1,host2"`).
- **`[ARGS...]`**: Any additional arguments to be passed directly to `ansible-playbook` (e.g., `-e var=value`).

Connection parameters like user and port are now managed via Ansible's inventory (`host_vars`), making the commands much cleaner.

### Example: Node Exporter

Deploys `node_exporter` to expose system-level metrics.

- **Deploy:**

  ```bash
  # Usage: just install node_exporter <HOSTS> [ARGS...]
  just install node_exporter 192.168.1.10
  just install node_exporter "px1,px2,px3" -e node_exporter_version=v1.8.0
  ```

- **Remove:**
  ```bash
  # Usage: just remove node_exporter <HOSTS> [ARGS...]
  just remove node_exporter 192.168.1.10
  ```

### Example: PVE Exporter

Deploys `prometheus-pve-exporter` to expose Proxmox VE metrics.

- **Deploy:**

  ```bash
  # Usage: just install pve_exporter <HOSTS> [ARGS...]
  just install pve_exporter px1 -e pve_token_value="my-secret-pve-token"
  ```

- **Remove:**
  ```bash
  # Usage: just remove pve_exporter <HOSTS> [ARGS...]
  just remove pve_exporter pve-host
  ```

### Example: Blackbox Exporter

Deploys `blackbox_exporter` for black-box probing of endpoints.

- **Deploy:**

  ```bash
  # Usage: just install blackbox_exporter <HOSTS> [ARGS...]
  just install blackbox_exporter 192.168.1.20
  ```

- **Remove:**
  ```bash
  # Usage: just remove blackbox_exporter <HOSTS> [ARGS...]
  just remove blackbox_exporter 192.168.1.20
  ```

### Example: Prometheus

Deploys `Prometheus`, a powerful monitoring solution and time series database.

- **Deploy:**

  ```bash
  # Usage: just install prometheus <HOSTS> [ARGS...]
  just install prometheus 192.168.1.30
  ```

- **Remove:**
  ```bash
  # Usage: just remove prometheus <HOSTS> [ARGS...]
  just remove prometheus 192.168.1.30
  ```

### Example: Firewall

Configures firewall rules declaratively using UFW or iptables.

- **Configure:**

  ```bash
  # Usage: just configure firewall <HOSTS> [ARGS...]
  just configure firewall 192.168.1.101
  ```

- **Host Configuration (inventory/host_vars/hostname.yml):**
  ```yaml
  firewall_rules:
    # SSH access from anywhere
    - port: 2222
      proto: tcp
      rule: allow
    # HTTPS only via Tailscale
    - port: 443
      proto: tcp
      interface: tailscale0
      rule: allow
    # Deny everything else (zero trust)
    - rule: deny
      direction: in
  ```

### Example: Smokeping Prober

Deploys `smokeping_prober` to perform latency monitoring.

- **Deploy:**
  ```bash
  # Usage: just install smokeping_prober <HOSTS> [ARGS...]
  just install smokeping_prober 192.168.1.40
  ```

- **Remove:**
  ```bash
  # Usage: just remove smokeping_prober <HOSTS> [ARGS...]
  just remove smokeping_prober 192.168.1.40 confirm_remove=true
  ```

- **Host Configuration (inventory/host_vars/hostname.yml):**
  The targets for the prober are configured via the `smokeping_prober_targets` variable. See the `Available Roles` section for a detailed example.

## Available Roles

The following roles are defined in this project. Their behavior can be customized by passing variables via extra arguments.

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

### `prometheus`

Installs and configures Prometheus.

| Variable              | Default Value           | Description                                        |
| :-------------------- | :---------------------- | :------------------------------------------------- |
| `prometheus_version`  | `"v2.54.1"`             | The version to install.                            |
| `prometheus_latest`   | `false`                 | If `true`, fetches the latest version from GitHub. |
| `prometheus_listen`   | `":9090"`               | The address and port for Prometheus to listen on.  |
| `prometheus_data_dir` | `"/var/lib/prometheus"` | The path for time series data storage.             |
| `prometheus_flags`    | `""`                    | Extra command-line flags for the service.          |

### `firewall`

Manages firewall rules declaratively with support for multiple backends.

| Variable           | Default Value | Description                                                 |
| :----------------- | :------------ | :---------------------------------------------------------- |
| `firewall_backend` | `"ufw"`       | Backend to use (`ufw` or `iptables`).                       |
| `firewall_state`   | `"enabled"`   | State of the firewall (`enabled` or `disabled`).            |
| `firewall_policy`  | `"deny"`      | Default policy for incoming traffic.                        |
| `firewall_reset`   | `true`        | Reset all rules before applying (declarative mode).         |
| `firewall_rules`   | `[]`          | **Required.** List of firewall rules (define in host_vars). |

**Rule Parameters:**

- `rule`: `allow` or `deny` (default: `allow`)
- `port`: Specific port number (optional)
- `proto`: `tcp` or `udp` (default: `tcp`)
- `src`: Source IP/subnet (optional)
- `interface`: Specific interface (optional)
- `direction`: `in` or `out` (default: `in`)

### `smokeping_prober`

Installs and configures the Prometheus Smokeping Prober.

| Variable                   | Default Value | Description                                                              |
| :------------------------- | :------------ | :----------------------------------------------------------------------- |
| `smokeping_prober_version` | `"0.10.0"`    | The version to install.                                                  |
| `smokeping_prober_listen`  | `":9374"`     | The address and port for the exporter to listen on.                      |
| `smokeping_prober_targets` | See defaults  | **Required.** The target configuration. Define this in your `host_vars`. |

**Target Configuration Example (`host_vars/myhost.yml`):**

```yaml
smokeping_prober_targets:
  targets:
    - name: "Google-DNS"
      hosts: [8.8.8.8, 8.8.4.4]
      interval: 2s
      protocol: icmp
    - name: "Cloudflare-DNS"
      hosts: [1.1.1.1, 1.0.0.1]
      interval: 2s
      protocol: icmp
```

## Adding a New Role

To add a new component or service, follow the existing structure:

1.  **Create the Role**: Add a new directory under `roles/` with the standard `tasks`, `templates`, `defaults`, and `handlers` subdirectories.
2.  **Create the Playbook**: Add a simple playbook in `playbooks/` that includes the new role. Create a corresponding `remove_...` playbook if needed.
3.  **Update the Justfile**: Add new recipes to the appropriate submodule (`install.just`, `remove.just`, etc.).
4.  **Update this README**: Document the new role and its usage instructions here.

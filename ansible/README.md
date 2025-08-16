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
  - [Example: Docker](#example-docker)
  - [Example: Docker Apps](#example-docker-apps)
  - [Example: Tailscale](#example-tailscale)
- [Available Roles](#available-roles)
  - [blackbox_exporter](#blackbox_exporter)
  - [node_exporter](#node_exporter)
  - [pve_exporter](#pve_exporter)
  - [prometheus](#prometheus)
  - [firewall](#firewall)
  - [smokeping_prober](#smokeping_prober)
  - [docker](#docker)
  - [docker_apps](#docker_apps)
  - [tailscale](#tailscale)
- [Adding a New Role](#adding-a-new-role)
- [Secrets Management (SOPS)](#secrets-management-sops)

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

Installs the Prometheus Blackbox Exporter. Configuration is managed via the `blackbox_exporter_config` variable.

| Variable                   | Default Value | Description                                                              |
| :------------------------- | :------------ | :----------------------------------------------------------------------- |
| `blackbox_exporter_version`| `"v0.27.0"`   | The version to install.                                                  |
| `blackbox_exporter_latest` | `false`       | If `true`, fetches the latest version from GitHub.                       |
| `blackbox_exporter_listen` | `":9115"`     | The address and port for the exporter to listen on.                      |
| `blackbox_exporter_config` | See defaults  | The configuration for the exporter. Define this in your `host_vars`.     |

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

Installs Prometheus. Configuration is managed via the `prometheus_config` variable.

| Variable             | Default Value           | Description                                                              |
| :------------------- | :---------------------- | :----------------------------------------------------------------------- |
| `prometheus_version` | `"v2.54.1"`             | The version to install.                                                  |
| `prometheus_latest`  | `false`                 | If `true`, fetches the latest version from GitHub.                       |
| `prometheus_listen`  | `":9090"`               | The address and port for Prometheus to listen on.                        |
| `prometheus_config`  | See defaults            | The configuration for Prometheus. Define this in your `host_vars`.       |

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

### Example: Docker

Installs Docker Engine on target hosts.

- **Install:**
  ```bash
  # Usage: just install docker <HOSTS> [ARGS...]
  just install docker px3-301
  ```

- **Remove:**
  ```bash
  # Usage: just remove docker <HOSTS> [ARGS...]
  just remove docker px3-301
  ```

### Example: Docker Apps

Deploys containerized applications using Docker Compose with flexible configuration management.

- **Deploy:**
  ```bash
  # Usage: just install docker_apps <HOSTS> [ARGS...]
  just install docker_apps px3-301
  ```

- **Host Configuration (`inventory/host_vars/hostname/docker_apps.yml`):**
  ```yaml
  docker_apps:
    - name: "whoami"
      enabled: true
    - name: "nginx-example"
      enabled: false
  ```

- **Group Configuration (`inventory/group_vars/docker_hosts/docker_compose/app-name.yml`):**
  ```yaml
  services:
    nginx:
      image: nginx:latest
      container_name: nginx-example
      restart: unless-stopped
  ```

- **Host-Specific Overrides (`inventory/host_vars/hostname/docker_compose/app-name.yml`):**
  ```yaml
  services:
    nginx:
      ports:
        - "8080:80"
  ```

### Example: Tailscale

Installs and configures Tailscale VPN.

- **Install:**
  ```bash
  # Usage: just install tailscale <HOSTS> [ARGS...]
  just install tailscale px3-301
  ```

- **Configure:**
  ```bash
  # Usage: just configure tailscale <HOSTS> [ARGS...]
  just configure tailscale px3-301
  ```

- **Remove:**
  ```bash
  # Usage: just remove tailscale <HOSTS> [ARGS...]
  just remove tailscale px3-301
  ```

### `docker`

Installs Docker Engine on target hosts.

| Variable      | Default Value | Description                                              |
| :------------ | :------------ | :------------------------------------------------------- |
| `docker_users` | `[]`         | List of users to add to the docker group for non-root access. |

### `docker_apps`

Deploys containerized applications using Docker Compose with flexible configuration management.

| Variable             | Default Value      | Description                                                           |
| :------------------- | :----------------- | :-------------------------------------------------------------------- |
| `docker_apps_base_dir` | `"/opt/docker-apps"` | Base directory where Docker Compose projects are deployed.            |
| `docker_apps`        | `[]`               | **Required.** List of applications to deploy (define in host_vars).   |

**Configuration Structure:**
- **Group configs**: `group_vars/docker_hosts/docker_compose/app-name.yml` (reusable base configurations)
- **Host configs**: `host_vars/hostname/docker_compose/app-name.yml` (host-specific overrides)
- **App list**: `host_vars/hostname/docker_apps.yml` (which apps are enabled per host)

Configurations are merged recursively, allowing host-specific customizations of group-defined services.

### `tailscale`

Installs and configures Tailscale VPN for secure mesh networking.

| Variable             | Default Value        | Description                                                    |
| :------------------- | :------------------- | :------------------------------------------------------------- |
| `tailscale_auth_key`   | `""`               | **Required.** Tailscale auth key for device registration.      |
| `tailscale_hostname`   | `"{{ ansible_hostname }}"` | Hostname to use for the Tailscale node.                   |
| `tailscale_expose_ssh` | `true`             | Whether to expose SSH through Tailscale.                       |
| `tailscale_is_exit_node` | `false`          | Whether to configure this node as an exit node.                |

**Host Configuration (`inventory/host_vars/hostname/secrets.sops.yml`):**
```yaml
tailscale_auth_key: "tskey-auth-xxxxxxxxxxxx"
```

## Adding a New Role

To add a new component or service, follow the existing structure:

1.  **Create the Role**: Add a new directory under `roles/` with the standard `tasks`, `templates`, `defaults`, and `handlers` subdirectories.
2.  **Create the Playbook**: Add a simple playbook in `playbooks/` that includes the new role. Create a corresponding `remove_...` playbook if needed.
3.  **Update the Justfile**: Add new recipes to the appropriate submodule (`install.just`, `remove.just`, etc.).
4.  **Update this README**: Document the new role and its usage instructions here.

## Secrets Management (SOPS)

This project uses [SOPS](https://github.com/getsops/sops) with [age](https://github.com/FiloSottile/age) encryption for managing sensitive data like API keys, tokens, and passwords.

### Configuration

SOPS is configured via `.sops.yaml` in the project root:

- **Encryption Keys**: Two age keys (`rus01`, `rus02`) are configured for redundancy
- **File Pattern**: Only files matching `inventory/(group_vars|host_vars)/.*/.*\.sops\.ya?ml$` are encrypted
- **Auto-encryption**: Files with `.sops.yml` extension are automatically encrypted when edited

### Encrypted Files

Current encrypted files in the project:
- `inventory/host_vars/px3-301/secrets.sops.yml` - Contains `tailscale_auth_key` and other host secrets

### Usage

**Edit encrypted files:**
```bash
sops inventory/host_vars/px3-301/secrets.sops.yml
```

**Create new encrypted file:**
```bash
sops inventory/host_vars/new-host/secrets.sops.yml
```

**View encrypted file:**
```bash
sops -d inventory/host_vars/px3-301/secrets.sops.yml
```

### Best Practices

- Store all sensitive variables in `secrets.sops.yml` files
- Use descriptive variable names (e.g., `tailscale_auth_key`, `api_token`)
- Keep non-sensitive config in regular YAML files
- Never commit unencrypted secrets to the repository

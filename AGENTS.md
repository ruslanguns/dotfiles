# Repository Guidelines

This repo is a declarative dotfiles and infrastructure setup managed with Nix Flakes and Home‑Manager for NixOS hosts, with Ansible for non‑Nix systems. Use the conventions below to keep changes reproducible, secure, and easy to review.

## Project Structure & Modules

- `nix/`: Flake entry (`flake.nix`), `hosts/`, `home/`, reusable `modules/`, `variables.json`, and `secrets.yaml` (SOPS‑encrypted).
- `ansible/`: Playbooks, roles, inventory, and its own `Justfile` for install/remove/config tasks.
- `config/`: Application configs (notably `nvim/`, `ssh/`).
- `scripts/`: Small utilities used across environments.
- Root `flake.nix` + `.envrc`: Dev shell (via `nix develop` or `direnv`) ensuring tools like `just`, `sops`, `ansible`, and formatters.

## Dev Environment & Entry

- With direnv: run `direnv allow` in the repo; the dev shell activates automatically.
- Without direnv: run `nix develop` to enter a shell providing the required tools.

## Build, Test, and Ops Commands

- Nix checks: `just nix check` (runs `nix flake check`), `just nix format` (formats with `nixpkgs-fmt`).
- Rebuilds: `just nix rebuild` (local) or `just nix rebuild_<host>` (e.g., `rebuild_wsl-01`, `rebuild_px1-105`).
- Bootstrap NixOS: `just nix setup_nixos <host> <user@ip>` for first‑time remote installs.
- Ansible: `just ansible install <role> <HOSTS>`, `just ansible remove <role> <HOSTS>`, `just ansible config <task> <HOSTS>`.
  - List module recipes: `just --list ansible`
  - Examples: `just ansible install node_exporter 192.168.1.10`, `just ansible install prometheus px1-105 -e prometheus_latest=true`.
- Secrets: `sops nix/secrets.yaml` to edit; manage keys in `nix/.sops.yaml`.
- Tmux workflow: `pux` to open/attach a project session (zoxide + tmux).

## Coding Style & Naming

- Nix: two‑space indent; small composable modules in `nix/modules/`; format with `nixpkgs-fmt`.
- Ansible/YAML: two spaces; snake_case names for roles/playbooks/vars; idempotent tasks; validate with `ansible-lint`.
- Lua (Neovim): two spaces; `column_width = 120` (see `config/nvim/stylua.toml`).
- Shell: prefer POSIX sh/bash with `set -euo pipefail`; keep scripts in `scripts/`.
- Justfiles: descriptive recipes; root delegates into `nix/` and `ansible/` modules.

## Quick Prerequisites

- Nix with flakes enabled; on first use run via `nix develop` or enable direnv + nix‑direnv, then `direnv allow`.
- Inventory and secrets for Ansible live under `ansible/inventory/host_vars/<hostname>/` (secrets often `secrets.sops.yml`).

## Testing & Validation

- Pre‑merge: `just nix check`, `just nix format`; `ansible-lint` on changed playbooks; run `yamllint`/`markdownlint` if editing YAML/MD.
- After changes: verify rebuild on the target host; check service status for Ansible‑managed units; confirm SOPS decryption when secrets/keys change.

## Commit & Pull Request Guidelines

- Commit style: `<scope>: <imperative summary>` where scope ∈ {`nix`, `home`, `ansible`, `nvim`, `tmux`, ...}.
  - Examples: `nix: add k3s manifests`, `ansible: fix docker_apps overrides`.
- PR checklist: concise description, motivation/impact, affected hosts/modules, commands run and results (logs for `nix check`, `ansible-lint`), and screenshots when UX‑visible.

## Secrets & Hosts

- Never commit plaintext secrets. Always edit via `sops nix/secrets.yaml`.
- New host flow: initial deploy may print an `age` key—add it to `nix/.sops.yaml` under the right rule, then redeploy.
- Host layout: `nix/hosts/<hostname>/` typically includes `default.nix`, `configuration.nix`, and `hardware-configuration.nix` (on bare metal).
- Ansible inventory: per‑host vars under `ansible/inventory/host_vars/<hostname>/` with SOPS‑encrypted secrets as needed.

## New Host Checklist

- Create `nix/hosts/<hostname>/` with `default.nix`, `configuration.nix`, and (bare metal) `hardware-configuration.nix`.
- Add or reuse a rebuild target in `nix/Justfile` (e.g., `rebuild_<hostname>`), or call `_local_with_host`/`_remote` as appropriate.
- Configure inventory: `ansible/inventory/host_vars/<hostname>/` and add `secrets.sops.yml` if required.
- Update `nix/.sops.yaml` with the host `age` key under the correct `creation_rules`.
- First deploy: `just nix setup_nixos <host> <user@ip>` → handle SOPS key → rerun.
- Validate: `just nix check`; run `ansible-lint` and a check‑mode apply on any changed playbooks.

## Ansible Examples

```bash
# Lint a single playbook
ansible-lint ansible/playbooks/node_exporter.yml

# Dry‑run (check mode) with diff from repo root via module
just ansible install node_exporter 192.168.1.10 -- --check --diff

# Pass extra vars safely after `--`
just ansible install prometheus px1-105 -- -e prometheus_latest=true
```

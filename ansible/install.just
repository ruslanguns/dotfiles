set shell := ["bash", "-euo", "pipefail", "-c"]

_default:
	@just --list --justfile "install.just"

# Installs node_exporter to specified hosts.
node_exporter HOSTS *ARGS:
  @just _run_playbook "node_exporter" "{{HOSTS}}" {{ARGS}}

# Installs pve_exporter to specified hosts.
pve_exporter HOSTS *ARGS:
  @just _run_playbook "pve_exporter" "{{HOSTS}}" {{ARGS}}

# Installs blackbox_exporter to specified hosts.
blackbox_exporter HOSTS *ARGS:
  @just _run_playbook "blackbox_exporter" "{{HOSTS}}" {{ARGS}}

# Installs prometheus to specified hosts.
prometheus HOSTS *ARGS:
  @just _run_playbook "prometheus" "{{HOSTS}}" {{ARGS}}


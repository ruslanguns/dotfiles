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

# Installs smokeping_prober to specified hosts.
smokeping_prober HOSTS *ARGS:
  @just _run_playbook "smokeping_prober" "{{HOSTS}}" {{ARGS}}

# Install docker
docker HOSTS *ARGS:
  @just _run_playbook "docker" "{{HOSTS}}" {{ARGS}}

# Install tailscale
tailscale HOSTS *ARGS:
  @just _run_playbook "tailscale" "{{HOSTS}}" {{ARGS}}

# Deploy docker applications
docker_apps HOSTS *ARGS:
  @just _run_playbook "docker_apps" "{{HOSTS}}" {{ARGS}}

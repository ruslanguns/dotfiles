set shell := ["bash", "-euo", "pipefail", "-c"]

_default:
	@just --list --justfile "remove.just"

# Removes node_exporter from specified hosts.
node_exporter HOSTS *ARGS:
  @just _run_playbook "remove_node_exporter" "{{HOSTS}}" {{ARGS}}

# Removes pve_exporter from specified hosts.
pve_exporter HOSTS *ARGS:
  @just _run_playbook "remove_pve_exporter" "{{HOSTS}}" {{ARGS}}

# Removes blackbox_exporter from specified hosts.
blackbox_exporter HOSTS *ARGS:
  @just _run_playbook "remove_blackbox_exporter" "{{HOSTS}}" {{ARGS}}

# Removes prometheus from specified hosts.
prometheus HOSTS *ARGS:
  @just _run_playbook "remove_prometheus" "{{HOSTS}}" {{ARGS}}

# Removes smokeping_prober from specified hosts.
smokeping_prober HOSTS *ARGS:
  @just _run_playbook "remove_smokeping_prober" "{{HOSTS}}" {{ARGS}}

# Removes docker from specified hosts.
docker HOSTS *ARGS:
  @just _run_playbook "remove_docker" "{{HOSTS}}" {{ARGS}}


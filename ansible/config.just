set shell := ["bash", "-euo", "pipefail", "-c"]

_default:
	@just --list --justfile "config.just"

# Applies firewall rules to specified hosts.
firewall HOSTS *ARGS:
  @just _run_playbook "firewall" "{{HOSTS}}" {{ARGS}}

# Applies configuration for prometheus without restarting the service.
prometheus HOSTS *ARGS:
  @just _run_playbook "configure_prometheus" "{{HOSTS}}" {{ARGS}}

set shell := ["bash", "-euo", "pipefail", "-c"]

_default:
	@just --list --justfile "config.just"

# Applies firewall rules to specified hosts.
firewall HOSTS *ARGS:
  @just _run_playbook "firewall" "{{HOSTS}}" {{ARGS}}

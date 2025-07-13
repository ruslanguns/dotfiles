# My Dotfiles

![Built with Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3.svg?style=for-the-badge&logo=nixos)
![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)

This repository contains my personal configuration files, managed declaratively with [NixOS](https://nixos.org/), [home-manager](https://github.com/nix-community/home-manager), and [sops-nix](https://github.com/Mic92/sops-nix).

## Philosophy

The goal of this project is to create a **reproducible, declarative, and automated** environment that can be deployed consistently across multiple machines. By defining the entire system configuration as code, from the operating system and services to user-level applications and shell settings, I can ensure a stable and predictable workflow everywhere.

- **Declarative:** I define _what_ the system should look like, and Nix handles _how_ to make it happen.
- **Reproducible:** [Nix Flakes](https://nixos.wiki/wiki/Flakes) pin all dependencies, guaranteeing that a configuration that works today will work the same way tomorrow.
- **Automated:** Setting up a new machine is reduced to a few simple commands.

## Table of Contents

- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Initial Installation](#initial-installation)
- [Daily Usage](#daily-usage)
  - [Applying Changes](#applying-changes)
  - [Managing Secrets](#managing-secrets)
  - [Code Maintenance](#code-maintenance)
- [Core Components & Workflows](#core-components--workflows)
  - [Neovim Setup](#neovim-setup)
  - [Tmux: The Preferred Multiplexer](#tmux-the-preferred-multiplexer)
  - [Fish Shell: Dynamic and Ensured Configuration](#fish-shell-dynamic-and-ensured-configuration)
- [Adapting for Your Own Use](#adapting-for-your-own-use)

## Key Features

- **Declarative Management:** The entire system is configured using the Nix language. [NixOS](https://nixos.org/) manages the system-level configuration, while [home-manager](https://github.com/nix-community/home-manager) handles the user environment, packages, and dotfiles.
- **Secure Secret Management:** Secrets are encrypted using [sops-nix](https://github.com/Mic92/sops-nix), allowing them to be safely stored in this public repository. Each host has its own unique key for decryption.
- **Integrated Development Environment:** A highly customized setup centered around **Neovim** and **Tmux**, providing a seamless and efficient workflow for development.
- **Multi-Host Support:** The configuration is designed to work on different types of machines, primarily **WSL (Windows Subsystem for Linux)** and **headless NixOS servers**.
- **Simple Command Interface:** A `Justfile` provides easy-to-remember commands for common tasks like building, deploying, and formatting.

## Project Structure

- `flake.nix`: The main entry point that defines all packages, hosts, and `home-manager` configurations.
- `Justfile`: A command runner that provides shortcuts for building and deploying configurations.
- `/nix/`: The core of the configuration.
  - `hosts/`: Contains the specific NixOS configurations for each machine.
  - `home/`: Contains user-specific configurations, managed by `home-manager`.
  - `modules/`: Reusable modules for configuring applications and services (e.g., `git.nix`, `tmux.nix`).
  - `variables.json`: A map of arbitrary key-value pairs (constants) that can be accessed throughout the Nix configuration. This helps centralize values used in multiple places.
  - `secrets.yaml`: The `sops`-encrypted secrets file.
- `/config/`: Non-Nix configuration files, such as for `nvim`.
- `/scripts/`: Miscellaneous helper scripts.

## Getting Started

Follow these steps to deploy this configuration on a new machine.

### Prerequisites

- [Nix](https://nixos.org/download.html) with Flakes support enabled.
- [Just](https://github.com/casey/just) command runner.
- [SOPS](https://github.com/getsops/sops) for secret management.

### Initial Installation

1.  **Install NixOS on the Target Machine**: Start with a minimal NixOS installation. Ensure it has network connectivity and SSH access.

2.  **Deploy the Configuration**: From your local machine, run the setup command. This will install the full configuration on the new remote machine.

    ```bash
    # Usage: just setup_nixos <host-name> <user@ip-address>
    just setup_nixos my-new-server user@192.168.1.X
    ```

3.  **Authorize SOPS Key (First-Time Only)**: The first build will likely fail because the new host doesn't have permission to decrypt secrets.

    - The error message will display the new host's public `age` key. Copy it.
    - Open `nix/.sops.yaml` in this repository and add the new key to the `keys` list under the appropriate `creation_rules`.
    - Run the deployment command again. The build should now succeed.

4.  **Final Setup**: After the first successful deployment, log into the new machine and follow the setup steps in the [Core Components & Workflows](#core-components--workflows) section below.

## Daily Usage

### Applying Changes

- **Apply to the local machine**:
  ```bash
  just nix_rebuild
  ```
- **Apply to a specific host**:

  ```bash
  # Example for WSL host
  just nix_rebuild_wsl-01

  # Example for remote server
  just nix_rebuild_px1-105
  ```

### Managing Secrets

- To edit encrypted secrets, run:
  ```bash
  sops nix/secrets.yaml
  ```
  This will open the decrypted file in your default editor. The file is automatically re-encrypted on save.

### Project Workflow

- A custom `pux` script is available to quickly launch or attach to a project-specific Tmux session using `zoxide`.
  ```bash
  # Select a project with fzf and jump into a tmux session
  pux
  ```

### Code Maintenance

- **Check Nix code syntax**:
  ```bash
  just nix_check
  ```
- **Format all Nix files**:
  ```bash
  just nix_format
  ```

## Adapting for Your Own Use

While this project is tailored for my personal use, it can be adapted by others.

- **SOPS-free Environment**: If you don't need secret management, the `generic` host configuration is a good starting point, as it does not import the `sops` module.
- **Using Your Own Secrets**: It is highly recommended to **fork** this project. This will allow you to configure `sops` with your own keys and manage your own `secrets.yaml` file securely.

## Core Components & Workflows

### Neovim Setup

The Neovim configuration is managed within this repository. To use it, follow these steps after the initial NixOS deployment:

1.  **Create a symbolic link**: The Neovim config from `config/nvim` must be linked to its default location (`~/.config/nvim`).
    ```bash
    ln -s $PWD/config/nvim ~/.config/nvim
    ```
2.  **Dependency Installation**: The Nix environment installs all necessary tools and programs (LSPs, formatters, etc.) for the configuration to be fully functional.
3.  **Copilot Authentication**: For the GitHub Copilot integration to work, you need to sign in from within Neovim. Run the following command inside `nvim`:
    ```vim
    :Copilot auth
    ```

### Tmux: The Preferred Multiplexer

This setup features a highly customized Tmux environment that serves as my primary terminal multiplexer.

- **Project-based Sessions**: A custom `pux` script is included, which uses `zoxide` to quickly launch or attach to a project-specific Tmux session.
  ```bash
  # Select a project with fzf and jump into a tmux session
  pux
  ```
- **Optimized for Neovim**: Keybindings and settings are fine-tuned for a smooth experience, including smart pane navigation (`Ctrl` + `h/j/k/l`) that works seamlessly between Tmux panes and Neovim splits.
- **Session Persistence**: Using `tmux-resurrect` and `tmux-continuum`, sessions are automatically saved and can be restored after a system reboot, preserving your workflow.
- **Modern UI**: Styled with the Catppuccin theme and a custom status bar that displays useful system information.
- **Efficient Keybindings**: The prefix is remapped to `C-a`. It includes intuitive shortcuts for splitting panes (`|` and `-`), resizing them without the prefix (`Ctrl+Alt` + `h/j/k/l`), and managing sessions with an `fzf`-based picker.

### Fish Shell Configuration

The Fish shell is configured for a productive environment, integrating tightly with Nix and providing several quality-of-life features.

**Core Features:**

- **Nix Integration:** Uses `any-nix-shell` to automatically load Nix development environments.
- **Dynamic Private Settings:** Loads a private configuration from `~/.env/fish_config.fish` on startup. This file is ideal for storing sensitive environment variables and is best managed with `sops-nix`.
- **Declarative Tooling:** A set of `ensure_*` functions (`ensure_nodejs`, `ensure_npm_packages`, `ensure_krew_plugins`) declaratively manage essential CLI tools. On shell startup, they install missing tools and remove extraneous ones to maintain a clean state. To customize, edit the `required_*` lists within these functions in `nix/modules/fish.nix`.
- **Node.js Management:** Integrates with `fnm` (Fast Node Manager) for handling Node.js versions.
- **Theming & Path:** Applies the `kanagawa.fish` theme and adds `~/.dotfiles/scripts` and `~/.krew/bin` to the `PATH`.

**Custom Functions & Helpers:**

- `refresh`: Reloads the Fish configuration.
- `take` / `ttake`: Creates and `cd`s into a new directory or a temporary directory.
- `show_path`: Displays each `PATH` entry on a new line.
- `posix-source`: Sources a `.env` file into the current shell.
- `justnix`: A shortcut for running `just` commands from the dotfiles root.
- `kubectl`: An alias for `kubecolor` to provide colorized output.

**Aliases and Abbreviations:**

- A rich set of abbreviations (`abbr`) are defined for common commands (e.g., `git`, `tmux`, navigation).
- Platform-specific aliases are provided for clipboard utilities (`xcopy`/`xpaste`) and file explorers.

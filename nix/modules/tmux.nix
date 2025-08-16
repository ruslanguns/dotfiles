{ pkgs, ... }:
let
  # =============================================================================
  # Custom Plugin Definitions
  # =============================================================================
  # These plugins are not available in the standard nixpkgs tmuxPlugins set
  # or require a specific version.

  # A session manager that uses fzf for quick session switching.
  t-smart-manager = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "t-smart-tmux-session-manager";
    version = "unstable-2023-01-06";
    rtpFilePath = "t-smart-tmux-session-manager.tmux";
    src = pkgs.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "t-smart-tmux-session-manager";
      rev = "a1e91b427047d0224d2c9c8148fb84b47f651866";
      sha256 = "sha256-HN0hJeB31MvkD12dbnF2SjefkAVgtUmhah598zAlhQs=";
    };
  };

  # Allows for opening or yanking on-screen text objects like file paths or URLs.
  tmux-super-fingers = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-super-fingers";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "artemave";
      repo = "tmux_super_fingers";
      rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
      sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
    };
  };

  # =============================================================================
  # Configuration Sections
  # =============================================================================
  # The extraConfig is split into logical blocks for readability and maintenance.

  # General settings for terminal behavior, colors, and status bar.
  generalSettings = ''
    # Use a 256-color terminal and enable RGB color support for modern terminals.
    set -g default-terminal "tmux-256color"
    set -ag terminal-overrides ",xterm-256color:RGB"

    # Position the status bar at the top of the screen.
    set-option -g status-position top
  '';

  # All keybindings, including prefix, pane navigation, and resizing.
  keybindings = ''
    # Remap the prefix from C-b to C-a for easier access.
    unbind-key C-b
    set-option -g prefix C-a
    bind-key C-a send-prefix

    # Intuitive pane splitting.
    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"

    # Resize panes using Ctrl+Alt+h/j/k/l without needing the prefix.
    bind -n C-M-j resize-pane -D 2
    bind -n C-M-k resize-pane -U 2
    bind -n C-M-l resize-pane -R 2
    bind -n C-M-h resize-pane -L 2

    # Popup window for quick commands.
    bind h display-popup -E
    bind -T popup q detach-client

    # Shortcuts to switch between specific project sessions.
    bind-key -T prefix C-w switch -t work1
    bind-key -T prefix C-r switch -t work2
    bind-key -T prefix C-d switch -t dotfiles
  '';

  # Configuration for vi-style copy mode.
  copyMode = ''
    # Use vi keybindings in copy mode for a consistent editing experience.
    set-window-option -g mode-keys vi

    # Bind keys for selection in vi copy mode.
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Enter copy mode instantly with the Escape key.
    bind Escape copy-mode
  '';

  # Integrations with other tools like Vim and the shell.
  integrations = ''
    # Smart pane navigation with Vim awareness.
    # Allows using C-h/j/k/l to navigate between tmux panes and Vim splits seamlessly.
    # See: https://github.com/christoomey/vim-tmux-navigator
    is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'";
    bind -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
    bind -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
    bind -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
    bind -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

    # Helper to detect if the current pane is running a shell.
    is_shell="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(bash|fish|zsh|sh|ksh)$'";

    # Alt+l: If in a shell, clear screen and refresh client. Otherwise, send C-l to the application.
    bind -n M-l if-shell "$is_shell" "send-keys C-l \; refresh-client" "send-keys C-l"

    # Capture pane content and open it in a new Neovim buffer.
    bind-key e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter
  '';

  # Mouse behavior and scrolling configuration.
  mouseSettings = ''
    # Enable full mouse support.
    set -g mouse on

    # Custom mouse wheel scrolling to work with alternate screen apps (like less, man).
    # This allows using the mouse wheel to send Up/Down arrow keys in such applications.
    # Pro tip: Use Shift + Mouse Wheel to enter copy mode and scroll the buffer.
    tmux_commands_with_legacy_scroll="nano less more man git"
    bind-key -T root WheelUpPane \
      if-shell -Ft= '#{?mouse_any_flag,1,#{pane_in_mode}}' \
        'send -Mt=' \
        'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
          "send -t= Up" "copy-mode -et="'

    bind-key -T root WheelDownPane \
      if-shell -Ft= '#{?pane_in_mode,1,#{mouse_any_flag}}' \
        'send -Mt=' \
        'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
          "send -t= Down" "send -Mt="'
  '';

  # Environment variables and plugin execution.
  environmentAndPlugins = ''
    # Manually load the CPU plugin for the status bar.
    run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux

    # Set environment variables for tmux to know its own configuration files and paths.
    set-environment -g TMUX_PROGRAM "${pkgs.tmux}/bin/tmux"
    set-environment -g TMUX_CONF "$HOME/.config/tmux/tmux.conf"
    set-environment -g TMUX_SOCKET "/tmp/tmux-$USER/default"
  '';

in
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0; # No delay for escape key, improving responsiveness with Neovim.
    secureSocket = false; # Use /tmp for sockets, required for WSL2 compatibility.
    terminal = "tmux-256color";
    historyLimit = 100000;

    plugins = with pkgs; [
      # --- Core Plugins ---
      tmuxPlugins.sensible # Sensible default settings for tmux.
      tmuxPlugins.better-mouse-mode # Improved mouse mode.
      tmuxPlugins.yank # Yank to system clipboard.
      tmuxPlugins.tmux-thumbs # Plugin for selecting and acting on text (e.g., file paths).

      # --- Session Management ---
      {
        plugin = tmuxPlugins.resurrect; # Persist tmux environment across reboots.
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum; # Automates saving and restoring sessions.
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
        '';
      }

      # --- UI and Theming ---
      {
        plugin = tmuxPlugins.catppuccin; # Catppuccin theme.
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -agF status-right "#{E:@catppuccin_status_cpu}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_uptime}"
          set -agF status-right "#{E:@catppuccin_status_battery}"
        '';
      }

      # --- Custom & Utility Plugins ---
      {
        plugin = t-smart-manager; # fzf-based session manager.
        extraConfig = ''
          set -g @t-fzf-prompt '  '
          set -g @t-bind "T"
        '';
      }
      {
        plugin = tmux-super-fingers; # Open or yank on-screen text.
        extraConfig = "set -g @super-fingers-key f";
      }
    ];

    # Combine all configuration blocks into the final extraConfig.
    extraConfig = ''
      ${generalSettings}
      ${keybindings}
      ${copyMode}
      ${integrations}
      ${mouseSettings}
      ${environmentAndPlugins}
    '';
  };

  # Enable tmate for easy pair programming sessions, inheriting the tmux config.
  programs.tmate = {
    enable = true;
  };

  # Add a 'pux' command to the environment.
  # This script uses zoxide to find a project directory and attaches to a
  # tmux session named after that project, creating it if it doesn't exist.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "pux";
      runtimeInputs = [
        pkgs.tmux
        pkgs.zoxide
      ];
      text = ''
        PRJ="$(zoxide query -i)"
        if [ -z "$PRJ" ]; then
          echo "No project selected."
          exit 1
        fi

        # Sanitize the project name to be used as a valid tmux session name (replace dots).
        SESSION_NAME="$(basename "$PRJ" | tr '.' '_')"

        echo "Launching tmux for project: $SESSION_NAME"

        # Change to the project directory before starting/attaching to tmux.
        # The `|| exit` ensures the script stops if the directory can't be entered.
        cd "$PRJ" || exit

        # Use the default tmux server.
        # -A: Attach to session if it exists, resizing clients.
        # -s: Specify session name.
        # If the session doesn't exist, a new one is created in the current directory ($PRJ).
        # `exec` replaces the current shell process, providing a seamless experience.
        exec tmux new-session -A -s "$SESSION_NAME"
      '';
    })
  ];
}

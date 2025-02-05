{ pkgs, ... }:
let
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
  tmux-browser = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-browser";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "ofirgall";
      repo = "tmux-browser";
      rev = "c3e115f9ebc5ec6646d563abccc6cf89a0feadb8";
      sha256 = "sha256-ngYZDzXjm4Ne0yO6pI+C2uGO/zFDptdcpkL847P+HCI=";
    };
  };
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
in
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0; # Stop tmux+escape craziness.
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      # tmux-nvim
      tmuxPlugins.tmux-thumbs
      {
        plugin = t-smart-manager;
        extraConfig = ''
          set -g @t-fzf-prompt '  '
          set -g @t-bind "T"
        '';
      }
      {
        plugin = tmux-super-fingers;
        extraConfig = "set -g @super-fingers-key f";
      }
      {
        plugin = tmux-browser;
        extraConfig = ''
          set -g @browser_close_on_deattach '1'
        '';
      }

      tmuxPlugins.sensible
      # must be before continuum edits right status bar
      # {
      #   plugin = tmuxPlugins.catppuccin;
      #   extraConfig = ''
      #     set -g @catppuccin_flavour 'frappe'
      #     set -g @catppuccin_window_tabs_enabled 'off'
      #     set -g @catppuccin_date_time "%H:%M"
      #   '';
      # }
      {
        plugin = tmuxPlugins.catppuccin;
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
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
    ];

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      set-option -g status-position top

      set -g mouse on

      unbind-key C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # Popup 
      bind h display-popup -E
      bind -T popup q detach-client

      # Change splits to match nvim and easier to remember
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Redimensionar paneles usando Ctrl+Alt+ h/j/k/l
      bind -n C-M-j resize-pane -D 2
      bind -n C-M-k resize-pane -U 2
      bind -n C-M-l resize-pane -R 2
      bind -n C-M-h resize-pane -L 2

      # Use vim keybindings in copy mode
      set-window-option -g mode-keys vi

      # v in copy mode starts making selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Escape turns on copy mode
      bind Escape copy-mode

      # Navegación inteligente entre panes con reconocimiento de Vim.
      # Ver: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

      # Cambiar de ventana con Ctrl + h/j/k/l
      bind-key -T prefix C-w switch -t work1
      bind-key -T prefix C-r switch -t work2
      bind-key -T prefix C-d switch -t dotfiles
      bind-key e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter

      # Detectar si estamos en un shell
      is_shell="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(bash|fish|zsh|sh|ksh)$'"

      # Ctrl+l: Si estamos en shell, limpiar y refrescar; de lo contrario, enviar C-l
      bind -n C-l if-shell "$is_shell" "send-keys C-l \; refresh-client" "send-keys C-l"

      # plugins
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux

      set-environment -g TMUX_PROGRAM "${pkgs.tmux}/bin/tmux"
      set-environment -g TMUX_CONF "$HOME/.config/tmux/tmux.conf"
      set-environment -g TMUX_SOCKET "/tmp/tmux-$USER/default"

      # Relead config is not working
      # bind r run "sh -c '\"$$TMUX_PROGRAM\" $${TMUX_SOCKET:+-S \"$$TMUX_SOCKET\"} source \"$$TMUX_CONF\"'" \; display "#{TMUX_CONF} sourced"
      # Emulate scrolling by sending up and down keys if these commands are running in the pane
      tmux_commands_with_legacy_scroll="nano less more man git"

      # Pro tip: Use Shift + Mouse Wheel to scroll up and down
      bind-key -T root WheelUpPane \
      if-shell -Ft= '#{?mouse_any_flag,1,#{pane_in_mode}}' \
        'send -Mt=' \
        'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
          "send -t= Up" "copy-mode -et="'

      bind-key -T root WheelDownPane \
      if-shell -Ft = '#{?pane_in_mode,1,#{mouse_any_flag}}' \
        'send -Mt=' \
        'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
          "send -t= Down" "send -Mt="'
    '';
  };

  programs.tmate = {
    enable = true;
    # extraConfig = config.xdg.configFile."tmux/tmux.conf".text;
  };

  home.packages = [
    # Open tmux for current project.
    (pkgs.writeShellApplication {
      name = "pux";
      runtimeInputs = [ pkgs.tmux ];
      text = ''
        PRJ="''$(zoxide query -i)"
        echo "Launching tmux for ''$PRJ"
        set -x
        cd "''$PRJ" && \
          exec tmux -S "''$PRJ".tmux attach
      '';
    })
  ];
}

if status is-interactive
    # Commands to run in interactive sessions can go here
    # eval (zellij setup --generate-auto-start fish | string collect)

    # PYENV
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
end

starship init fish | source

set fish_greeting ""

function gityo
    git config user.name "Ruslan Gonzalez"
    git config user.email "ruslanguns@gmail.com"
    git config user.signingkey 905CCD44E212ABF4
    git config commit.gpgSign true
    echo "Configuración de Git aplicada: Ruslan Gonzalez - Personal"
end

function bat --wraps=batcat --description 'Alias de batcat con autocompletado'
    batcat $argv
end

abbr -a --global k kubectl

set EDITR nvim

# fnm
set PATH "/home/rus/.local/share/fnm" $PATH
fnm env | source

function kubectl
    kubecolor $argv
end


set -Ux NIXPKGS_ALLOW_UNFREE 1

set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin
set -U fish_user_paths $HOME/.nix-profile/bin $fish_user_paths
set -U fish_user_paths $fish_user_paths ~/.local/bin
pyenv init - | source

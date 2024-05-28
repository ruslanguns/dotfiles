if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
set -gx EDITOR nvim
set fish_greeting

# reuse "kubectl" completions on "kubecolor"
function kubecolor --wraps kubectl
    command kubecolor $argv
end

# adds alias for "kubectl" to "kubecolor" with completions
function kubectl --wraps kubectl
    command kubecolor $argv
end

# adds alias for "k" to "kubecolor" with completions
function k --wraps kubectl
    command kubecolor $argv
end

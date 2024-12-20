set __fish_kubectl_timeout "--request-timeout=$FISH_KUBECTL_COMPLETION_TIMEOUT"


function __fish_kubectl
    set -l context_args

    if set -l context_flags (__fish_kubectl_get_context_flags | string split " ")
        for c in $context_flags
            set context_args $context_args $c
        end
    end

    command kubectl $__fish_kubectl_timeout $context_args $argv
end

function __fish_kubectl_get_context_flags
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq 0 ]
        return 1
    end

    set -l foundContext 0

    for c in $cmd
        test $foundContext -eq 1
        set -l out "--context" "$c"
        and echo $out
        and return 0

        if string match -q -r -- "--context=" "$c"
            set -l out (string split -- "=" "$c" | string join " ")
            and echo $out
            and return 0
        else if contains -- "$c" "--context"
            set foundContext 1
        end
    end

    return 1
end

function __fish_kubectl_get_ns_flags
    set -l cmd (commandline -opc)
    if [ (count $cmd) -eq 0 ]
        return 1
    end

    set -l foundNamespace 0

    for c in $cmd
        test $foundNamespace -eq 1
        set -l out "--namespace" "$c"
        and echo $out
        and return 0

        if contains -- $c $__kubectl_all_namespaces_flags
            echo "--all-namespaces"
            return 0
        end

        if contains -- $c "--namespace" "-n"
            set foundNamespace 1
        end
    end

    return 1
end

function __fish_kubectl_print_resource -d 'Print a list of resources' -a resource
    set -l args

    set args $args get "$resource" -o name
    __fish_kubectl $args | string replace -r '(.*)/' ''
end

function __fish_kubectl_get_config -a type
    set -l template "{{ range .$type }}"'{{ .name }}{{"\n"}}{{ end }}'
    __fish_kubectl config view -o template --template="$template"
end

complete -f -c stern -a "$cmd"
complete -f -c stern -l all-namespaces -s A -d 'If present, tail across all namespaces. A specific namespace is ignored even if specified with --namespace.'
complete -f -c stern -r -l color -d 'Color output. Defaults to "auto"' -a "always never auto"
complete -f -c stern -r -l container -s c -d 'Container name when multiple containers in pod (default ".*")'
complete -f -c stern -r -l container-state -d 'If present, tail containers with status in running, waiting or terminated. Default to running. (default "running")'
complete -f -c stern -r -l context -d 'Kubernetes context to use. Default to current context configured in kubeconfig.' -a "(__fish_kubectl_get_config contexts)"
complete -f -c stern -r -l exclude -s e -d 'Regex of log lines to exclude'
complete -f -c stern -r -l exclude-container -s E -d 'Exclude a Container name'
complete -f -c stern -r -l exclude-pod -d 'Pod name to exclude. (regular expression)'
complete -f -c stern -r -l field-selector -d 'Selector (field query) to filter on. If present, default to ".*" for the pod-query.'
complete -f -c stern -l help -s h -d 'Show help for stern'
complete -f -c stern -r -l include -s i -d 'Regex of log lines to include'
complete -f -c stern -r -l init-containers -d 'Include or exclude init containers (default true)'
complete -f -c stern -r -l kubeconfig -d 'Path to kubeconfig file to use'
complete -f -c stern -r -l namespace -s n -d 'Kubernetes namespace to use. Default to namespace configured in Kubernetes context' -a "(__fish_kubectl_print_resource namespaces)"
complete -f -c stern -r -l output -s o -d 'Predefined output template.' -a "default raw json"
complete -f -c stern -r -l prompt -s p -d "Toggle interactive prompt for selecting 'app.kubernetes.io/instance' label values"
complete -f -c stern -r -l selector -s l -d 'Selector (label query) to filter on. If present, defaults to ".*"'
complete -f -c stern -r -l since -s s -d 'Return logs newer than a relative duration like 5s, 2m, or 3h. Defaults to 48h.'
complete -f -c stern -r -l tail -d 'The number of lines from the end of the logs to show. Defaults to showing all logs.'
complete -f -c stern -r -l template -d 'Template to use for log lines, leave empty to use --output flag'
complete -f -c stern -r -l timestamps -s t -d 'Print timestamps'
complete -f -c stern -r -l timezone -d 'Set timestamps to specific timezone. (default "Local")'
complete -f -c stern -l version -d 'Print the version and exit'

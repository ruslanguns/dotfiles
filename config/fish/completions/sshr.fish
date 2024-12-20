function __list_hosts
    cat ~/.config/hosts.txt
end

complete -c sshr -f -a "(__list_hosts)" -d "Host available in ~/.config/hosts.txt"

function portsearch
    sudo lsof -i :$argv[1]
end

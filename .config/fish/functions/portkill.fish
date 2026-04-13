function portkill
    sudo kill (sudo lsof -t -i :$argv[1])
end

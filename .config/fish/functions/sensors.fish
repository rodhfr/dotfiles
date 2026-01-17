function sensors --wraps='watch -n 1 sensors' --description 'alias sensors=watch -n 1 sensors -f'
    watch -n 1 sensors $argv
end

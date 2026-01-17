function chrome --wraps='flatpak run com.google.Chrome' --description 'alias chrome=flatpak run com.google.Chrome'
    flatpak run com.google.Chrome $argv
end

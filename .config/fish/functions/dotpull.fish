function dotpull --description "pull dotfiles"
    git -C "$HOME/dotfiles" pull
    and stow --dir="$HOME/dotfiles" --target="$HOME" .
end

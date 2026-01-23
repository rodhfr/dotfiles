starship init fish | source

set PATH $PATH /home/rodhfr/.local/bin
set PATH $PATH /home/rodhfr/go/bin/
set EDITOR nvim
set SWAYSOCK /run/user/1000/sway-ipc.1000.1111939.sock

zoxide init fish | source

if test -d /home/linuxbrew/.linuxbrew # Linux
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
end
fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"

! set -q MANPATH; and set MANPATH ''
set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH

! set -q INFOPATH; and set INFOPATH ''
set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH

set -x MANPAGER "nvim +Man!"

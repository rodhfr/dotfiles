# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc
. "$HOME/.cargo/env"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

export MANPAGER="nvim +Man!"
export MANPAGER="sh -c 'nvim -c \"Man \$1\" -'"

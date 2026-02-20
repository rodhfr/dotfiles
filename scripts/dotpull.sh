#!/usr/bin/env bash

set -e

git -C "$HOME/dotfiles" pull
stow --dir="$HOME/dotfiles" --target="$HOME" .

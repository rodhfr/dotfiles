#!/usr/bin/env bash

sudo dnf install -y git gh stow

gh auth login

gh repo clone rodhfr/dotfiles "$HOME/dotfiles"
gh repo clone rodhfr/dotfiles_secret "$HOME/dotfiles_secret"

GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Aplica stow
apply_stow() {
  local path=$1
  echo -e "🔗 Aplicando stow em $path..."
  cd "$path" || exit 1
  stow .
  echo -e "${GREEN}✅ Stow aplicado em $path${RESET}"
}

apply_stow "$HOME/dotfiles"
apply_stow "$HOME/dotfiles_secret"

echo -e "${GREEN}🎉 Dotfiles instalados com sucesso!${RESET}"

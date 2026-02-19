#!/usr/bin/env bash

GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

sudo dnf install -y git gh stow cronie
gh auth login

clone_if_needed() {
  local repo=$1
  local dest=$2
  if [ -d "$dest" ]; then
    echo -e "⚠️  $dest já existe, pulando clone..."
  else
    gh repo clone "$repo" "$dest"
  fi
}

apply_stow() {
  local path=$1
  echo -e "🔗 Aplicando stow em $path..."
  cd "$path" || exit 1
  stow .
  echo -e "${GREEN}✅ Stow aplicado em $path${RESET}"
}

clone_if_needed "rodhfr/dotfiles" "$HOME/dotfiles"
clone_if_needed "rodhfr/dotfiles_secret" "$HOME/dotfiles_secret"

apply_stow "$HOME/dotfiles"
apply_stow "$HOME/dotfiles_secret"

echo -e "${GREEN}🎉 Dotfiles instalados com sucesso!${RESET}"

(
  crontab -l 2>/dev/null
  echo "0 2 * * * $HOME/dotfiles/update_v4.sh >> /tmp/update_v4.log 2>&1"
) | crontab -

# exec post install script
bash "$HOME/dotfiles/post_install.sh"

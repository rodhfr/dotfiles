#!/usr/bin/env bash

GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

sudo -v < /dev/tty
(
  trap - INT
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done
) 2>/dev/null &
SUDO_PID=$!

trap 'echo -e "\n${RED}❌ Cancelado pelo usuário.${RESET}"; kill "$SUDO_PID" 2>/dev/null; exit 130' INT

SETUP_FLAG="$HOME/.config/dotfiles/setup_done"

if [ ! -f "$SETUP_FLAG" ]; then
  echo -e "Esta máquina é [r]eceptora (pull/restore) ou [e]nviadora (push/backup)? [r/e]: "
  read -r MACHINE_ROLE </dev/tty

  read -rp "Digite o hostname desta máquina: " NEW_HOSTNAME </dev/tty
  sudo hostnamectl set-hostname "$NEW_HOSTNAME"

  mkdir -p "$(dirname "$SETUP_FLAG")"
  echo "$MACHINE_ROLE" >"$SETUP_FLAG"
  echo -e "${GREEN}✅ Setup inicial concluído (hostname: $NEW_HOSTNAME)${RESET}"
fi

sudo dnf up -y
sudo dnf install -y git gh stow cronie
gh auth status &>/dev/null || gh auth login
gh auth setup-git

clone_if_needed() {
  local repo=$1
  local dest=$2
  if [ -d "$dest" ]; then
    echo -e "⚠️  $dest já existe, pulando clone..."
    echo -e "⚠️  Fazendo pull from remote..."
    git -C "$dest" pull
  else
    gh repo clone "$repo" "$dest"
  fi
}

apply_stow() {
  local path=$1
  echo -e "🔗 Aplicando stow em $path..."
  cd "$path" || exit 1
  stow --adopt --no-folding --ignore='\.wants' . || {
    echo -e "${RED}❌ Erro ao aplicar stow em $path${RESET}"
    exit 1
  }
  echo -e "${GREEN}✅ Stow aplicado em $path${RESET}"
}

clone_if_needed "rodhfr/dotfiles" "$HOME/dotfiles"
clone_if_needed "rodhfr/dotfiles_secret" "$HOME/dotfiles_secret"

apply_stow "$HOME/dotfiles"
apply_stow "$HOME/dotfiles_secret"

echo -e "${GREEN}🎉 Dotfiles instalados com sucesso!${RESET}"

MACHINE_ROLE=$(cat "$SETUP_FLAG")

if [[ "$MACHINE_ROLE" =~ ^[Ee] ]]; then
  CRON_CMD="$HOME/dotfiles/scripts/update_v4.sh > /tmp/update_v4.log 2>&1"
else
  CRON_CMD="git -C $HOME/dotfiles pull && git -C $HOME/dotfiles_secret pull > /tmp/dotfiles_pull.log 2>&1"
fi

CRON_LINE="0 2 * * * $CRON_CMD"
(
  crontab -l 2>/dev/null | grep -vF "$HOME/dotfiles/scripts/"
  echo "$CRON_LINE"
) | crontab -

# exec post install script
bash "$HOME/dotfiles/scripts/post_install.sh"

read -rp "Deseja reiniciar o computador agora? [s/N]: " REBOOT_ANSWER </dev/tty
if [[ "$REBOOT_ANSWER" =~ ^[Ss]$ ]]; then
  echo -e "${GREEN}🔄 Reiniciando...${RESET}"
  sudo reboot
fi

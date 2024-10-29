#!/bin/bash


# Prompt the user for network configuration
read -p "Do you want to configure the network? (y/n): " response

# Convert response to lowercase
response=${response,,}

if [[ "$response" == "y" ]]; then
    echo "Starting network configuration..."
    sudo apt install -y \
      network-manager \
      network-manager-config-connectivity-debian \

    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManagerk
    sudo systemctl status NetworkManager
    echo "Needed dependencies installed, launching nmtui for network configuration"
    nmtui
    echo "Network configured successfully."
else
    echo "Network configuration skipped."
fi

# Ping google.com to check network connectivity
echo "Checking if network is reachable..."
if ping -c 3 google.com &> /dev/null; then
    echo "Network is reachable."

else
    echo "Network is unreachable. Exiting script. Retry network configuration."
    exit 1
fi

# Function to check if a command is installed
check_installed() {
    if command -v "$1" > /dev/null; then
        echo "$1 is installed"
    else
        echo "$1 is not installed, there is a problem."
        exit 1  # Exit the script if the command is not installed
    fi
}

# WARNINGS
echo "Intended for fresh installs of Debian 12"
echo "This script will remove your currently existing configs for lvim, sway, kitty, mpv, ranger, lazygit, neovim"
echo "Make sure to backup your ~/.config/ folder"
read -p "Do you wish to continue? (y/n): " answer

if [[ "$answer" == "y" ]]; then
  echo "Starting installation..."
  echo "Installing some basic packages"
  sudo apt update 
  sudo apt upgrade -y
  if ! sudo apt install -y \
      git \
      tar \
      curl \
      wget \
      flatpak \
      build-essential \
      python3-pip \
      wl-clipboard \
      kitty \
      clipman \
      ranger \
      fuzzel \
      pipx \
      grimshot \
      ripgrep \
      playerctl \
      mpv \
      rclone \
      pamixer \
      python3-pynvim \
      python-pip \
      make \
      pavucontrol \
      pulseaudio-utils \
      python-is-python3 \
      upower \
      upower-doc \
      yt-dlp; then
      echo "Failed to install packages." >&2
      exit 1

  fi
  echo "Basic packages successfully installed"

  # Add FlatHub
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  
  # Removing old installation of neovim, debian has old version for lunarvim
  sudo apt remove -y neovim

  # Backing up old config files
  backup_folder="$HOME/.config/SwaySetup_backup_old_config/"
  mkdir -p "$backup_folder"
  # Move existing configuration folders to backup
  [ -d "$HOME/.config/sway/" ] && mv -v "$HOME/.config/sway/" "$backup_folder"
  [ -d "$HOME/.config/lvim/" ] && mv -v "$HOME/.config/lvim/" "$backup_folder"
  [ -d "$HOME/.config/neovim/" ] && mv -v "$HOME/.config/neovim/" "$backup_folder"
  [ -d "$HOME/.config/mpv/" ] && mv -v "$HOME/.config/mpv/" "$backup_folder"
  [ -d "$HOME/.config/kitty/" ] && mv -v "$HOME/.config/kitty/" "$backup_folder"
  [ -d "$HOME/.config/ranger/" ] && mv -v "$HOME/.config/ranger/" "$backup_folder"
  [ -d "$HOME/.config/lazygit/" ] && mv -v "$HOME/.config/lazygit/" "$backup_folder"
  
  # Creating folders "Permission check"
  mkdir -p "$HOME/.config/sway/"
  mkdir -p "$HOME/.config/lvim/"
  mkdir -p "$HOME/.config/neovim/"
  mkdir -p "$HOME/.config/kitty/"
  mkdir -p "$HOME/.config/mpv/"
  mkdir -p "$HOME/.config/ranger/"
  mkdir -p "$HOME/.config/lazygit/"
  mkdir -p "$HOME/.config/.BuildSwaySetup"

  # Cloning dotfiles
  git clone "https://github.com/rodhfr/dotfiles.git" "$HOME/.config/.BuildSwaySetup/"
  # Moving dotfiles with overwrite
  cp -rf "$HOME/.config/.BuildSwaySetup/dotfiles/"* "$HOME/.config/"
  # Removing cached dotfiles
  rm -r "$HOME/.config/.BuildSwaySetup"


  # ---- Install Lunarvim 0.9.5 ----
  # -- Dependencies --

  # Symlink Neovim binary
  if [ -f "$HOME/.config/neovim/bin/nvim" ]; then
      sudo ln -s "$HOME/.config/neovim/bin/nvim" /usr/bin/
      sudo chmod +x /usr/bin/nvim
      echo "Symlink for Neovim created"
  else
      echo "Neovim binary not found, skipping symlink creation."
  fi

  # Symlink Lazygit binary
  if [ -f "$HOME/.config/lazygit/lazygit" ]; then
      sudo ln -s "$HOME/.config/lazygit/lazygit" /usr/bin/
      sudo chmod +x /usr/bin/lazygit
      echo "Symlink for Lazygit created"
  else
      echo "Lazygit binary not found, skipping symlink creation."
  fi

  # Setup Rust Latest
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default --no-modify-path
  echo "export PATH=\$HOME/.local/bin:\$PATH" >> "$HOME/.bashrc"
  source "$HOME/.bashrc"
  check_installed rustc

  # Install NVM (version manager for node)
  echo "Installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  # Export nvm variables
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  # Install Node.js + npm
  echo "Installing Node.js + npm via nvm"
  check_installed nvm
  nvm install node
  check_installed node

  # just in case before installing Lunarvim
  source "$HOME/.bashrc"
  
  # -- LunarVim Installation -- 
  LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

  echo "Installation completed successfully."
  echo "Your old config files were backed up to $backup_folder"

elif [[ "$answer" == "n" ]]; then
  echo "Exiting..."
else
  echo "Invalid input. Please enter 'y' or 'n'. Press 'Ctrl+C' to exit"

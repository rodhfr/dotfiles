#!/bin/bash


# Function to check if a command is installed
check_installed() {
    if command -v "$1" > /dev/null; then
        echo "$1 is installed"
    else
        echo "$1 is not installed, there is a problem."
        exit 1  # Exit the script if the command is not installed
    fi
}
# Function to create symlink
create_symlink() {
    if [ -f "$1" ]; then
        sudo ln -s "$1" "$2"
        sudo chmod +x "$2"
        echo "Symlink created for $1 at $2"
    else
        echo "$1 not found, skipping symlink creation."
    fi
}

# Prompt the user for network configuration
read -p "Do you want to configure the network? (y/n): " response

# Convert response to lowercase
response=${response,,}

if [[ "$response" == "y" ]]; then
    echo "Starting network configuration..."
    if ! sudo apt install -y network-manager network-manager-config-connectivity-debian; then
        echo "Failed to install network manager packages." >&2
        exit 1
    fi
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
    echo "Needed dependencies installed, launching nmtui for network configuration"
    sudo nmtui
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
      unzip \
      fonts-noto-color-emoji \
      fonts-recommended \
      fonts-firacode \
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
      firefox-esr \
      grimshot \
      ripgrep \
      playerctl \
      mpv \
      rclone \
      pamixer \
      python3-pynvim \
      pcmanfm-qt \
      python3-pip \
      make \
      pavucontrol \
      pulseaudio-utils \
      python-is-python3 \
      upower \
      brightnessctl \
      jq \
      python3-i3ipc \
      xwayland \
      qtbase5-dev \
      qt5-qmake \
      qtbase5-dev-tools \
      qtwayland5 \
      qt6-wayland \
      qt6-wayland-dev \
      libxcb-xinerama0 \
      libxcb-xinerama0-dev \
      xdg-desktop-portal-wlr \
      xdg-desktop-portal-gtk \
      flatpak-xdg-utils \
      yt-dlp; then
      echo "Failed to install packages." >&2
      exit 1
  fi

  echo "Basic packages successfully installed"

  # Add FlatHub
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  # program to config inputs via gui
  pipx install sway-input-config
  pipx install autotiling
  
  # Removing old installation of neovim, debian has old version for lunarvim
  sudo apt remove -y \
    neovim \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome

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
  [ -d "$HOME/.config/pcmanfm-qt/" ] && mv -v "$HOME/.config/pcmanfm-qt/" "$backup_folder"
  
  cp -r "./" "$HOME/.config/"

  # ---- Install Lunarvim 0.9.5 ----
  # -- Dependencies --
  
  # Symlink Neovim binary
  create_symlink "$HOME/.config/neovim/bin/nvim" /usr/bin/nvim
  check_installed nvim

  # Symlink Lazygit binary
  #create_symlink "$HOME/.config/lazygit/lazygit" /usr/bin/lazygit

  # Setup Rust Latest
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  echo "export PATH=\$HOME/.local/bin:\$PATH" >> "$HOME/.bashrc"
  echo ". $HOME/.cargo/env" >> "$HOME/.bashrc"
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
  
  ### -- LunarVim Installation -- 
  LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

  ### Install fonts
  FONT_DIR="./fonts/JetBrainsMonoNerdFontPropo-Regular.ttf"  
  FONT_FILE2="./fonts/TerminusTTF-4.49.3.ttf"
  mkdir -p "$HOME/.fonts/"
  mkdir -p "$HOME/.local/share/fonts"
  FONT_DIR="$HOME/.local/share/fonts"
  SYSTEM_FONT_DIR="/usr/share/fonts"

 # creating dir for fonts
  mkdir -p "$FONT_DIR"
  sudo mkdir -p "$SYSTEM_FONT_DIR"

  # copying fonts
  cp "$FONT_FILE" "$FONT_DIR/"
  sudo cp "$FONT_FILE2" "$SYSTEM_FONT_DIR"

  echo "Updating font cache..."
  fc-cache -f -v
  echo "Font installed successfully!"

  # autoremove and check for futher upgrades
  sudo apt autoremove -y
  sudo apt update
  sudo apt upgrade -y

  ### Finish program
  echo "Installation completed successfully."
  echo "Your old config files were backed up to $backup_folder"
  echo "WARN: For Flatpak to work a system reboot is needed."


elif [[ "$answer" == "n" ]]; then
  echo "Exiting..."
else
  echo "Invalid input. Please enter 'y' or 'n'. Press 'Ctrl+C' to exit"
fi

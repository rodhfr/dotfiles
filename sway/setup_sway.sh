#!/bin/bash

# WARNINGS
echo "This script will remove your currently existing lunar vim installation or neovim for what matters"
echo "Do you which to continue? (y/n): " answer

if [[ "$answer" == "y"]]; then
  echo "Starting installation..."
  sudo apt update 
  sudo apt upgrade -y

  sudo apt install -y \
    git \
    flatpak \
    gnome-software-plugin-flatpak \
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
    pamixer \
    pavucontrol \
    pulseaudio-utils \
    clipman \
  
  # Set up Python alias
  echo "alias python=python3" >> ~/.bashrc
  echo "Alias for python3 as python added to .bashrc"
  
  sudo apt remove -y \
    neovim

  backup_folder="$HOME/.config/SwaySetup_backup_old_config/"
  mkdir -p "$backup_folder"
  sudo mv "$HOME/.config/sway/" "$backup_folder"
  sudo mv "$HOME/.config/lvim/" "$backup_folder"
  sudo mv "$HOME/.config/neovim/" "$backup_folder" 
  
  sudo mkdir -p "$HOME/.config/sway/"
  sudo mkdir -p "$HOME/.config/lvim/"
  sudo mkdir -p "$HOME/.config/neovim/"

  
  
  # Install Lunar for Neovim 0.9.5 
  
  # Setup Rust Latest
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default --no-modify-path
  echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc
  # Dependencies:
  # Symlink Neovim 0.9.5 binary
  sudo ln -s ~/.config/neovim/bin/nvim /usr/bin/nvim
  sudo chmod +x /usr/bin/nvim
  echo "Symlink for Neovim created"
  sudo apt install -y \
    python3-pynvim \
    make \
    ripgrep \
    git \
  
  
  
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

elif [[ "$answer" == "f"]]; then
  echo "Exiting..."
else
  echo "Invalid input. Please enter 'y' or 'f'. Press 'Ctrl+C' to exit"

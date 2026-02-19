#!/usr/env/bin bash

set_intel_video_drivers() {
  # Detect CPU vendor
  CPU_VENDOR=$(awk -F': ' '/vendor_id/ {print $2; exit}' /proc/cpuinfo)
  if [[ "$CPU_VENDOR" != "GenuineIntel" ]]; then
    echo "Non-Intel CPU detected. Skipping configuration."
    return 0
  fi

  # Ask for hostname
  read -rp "Enter hostname: " HOSTNAME
  sudo hostnamectl set-hostname "$HOSTNAME"

  # Detect Intel CPU model name
  CPU_MODEL=$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo)

  # Extract Intel generation from model number
  # Examples:
  # i7-4770  -> Gen 4 (Haswell)
  # i5-8250U -> Gen 8
  # i7-10700 -> Gen 10
  if [[ "$CPU_MODEL" =~ i[3579]-([0-9]{4,5}) ]]; then
    MODEL_NUM="${BASH_REMATCH[1]}"
    if ((${#MODEL_NUM} == 4)); then
      GEN="${MODEL_NUM:0:1}"
    else
      GEN="${MODEL_NUM:0:2}"
    fi
  else
    echo "Unable to determine Intel generation. Assuming newer than Haswell."
    GEN=5
  fi

  if ((GEN <= 4)); then
    echo "Detected Intel Haswell or older (Gen $GEN). Installing legacy driver."
    sudo dnf install -y libva-intel-driver
  else
    echo "Detected Intel newer than Haswell (Gen $GEN). Installing modern driver."
    sudo dnf install -y intel-media-driver
    sudo dnf install -y libva-intel-driver # legacy compat layer, remove if not needed
  fi
}

setup_git_identity() {
  # Check existing Git username and email
  local current_username
  local current_email

  current_username=$(git config --global user.name)
  current_email=$(git config --global user.email)

  # Set username if not already set
  if [ -z "$current_username" ]; then
    read -rp "Enter your Git username: " git_username
    git config --global user.name "$git_username"
    echo "Git username set to: $git_username"
  else
    echo "Git username already set to: $current_username"
  fi

  # Set email if not already set
  if [ -z "$current_email" ]; then
    read -rp "Enter your Git email: " git_email
    git config --global user.email "$git_email"
    echo "Git email set to: $git_email"
  else
    echo "Git email already set to: $current_email"
  fi

  echo "Setting default branch to main..."
  git config --global init.defaultBranch main
  echo "Ok."
}

sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf group upgrade core -y
sudo dnf4 group install core -y
sudo dnf -y update

sudo dnf4 group install multimedia -y
sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing                                                   # Switch to full FFMPEG.
sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video                                                                # Installs useful Sound and Video complementary packages.

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo dnf in -y \
  fzf \
  fuse-libs \
  pipx \
  rclone \
  neovim \
  unzip \
  p7zip \
  p7zip-plugins \
  unrar
mpv \
  go \
  fzf \
  tldr \
  zoxide \
  nautilus-python \
  git \
  fish

pipx install \
  flatgrep

# Install flatpaks
flatpak install -y --user \
  com.mattjakeman.ExtensionManager \
  it.mijorus.gearlever

# startship install
curl -sS https://starship.rs/install.sh | sh
curl -LsSf https://astral.sh/uv/install.sh | sh

# setup shell
sudo chsh -s /usr/bin/fish
set -U fish_user_paths ~/.local/bin/flatgrep

# setup git
setup_git_identity

# video driver intel
set_intel_video_drivers

# firefox default page
sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js

# setup firewall
sudo firewall-cmd --permanent --zone=public --add-service=kdeconnect
sudo firewall-cmd --permanent --zone=public --add-service=ssh

alias n="nvim"
alias cls="clear"
alias c="cd"
alias p="pwd"
alias l="ls"
set -gx EDITOR nvim

# Keyd install
sudo dnf copr -y enable alternateved/keyd
sudo dnf install keyd -y

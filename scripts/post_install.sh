#!/usr/env/bin bash

sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

set_intel_video_drivers() {
  # Detect CPU vendor
  CPU_VENDOR=$(awk -F': ' '/vendor_id/ {print $2; exit}' /proc/cpuinfo)
  if [[ "$CPU_VENDOR" != "GenuineIntel" ]]; then
    echo "Non-Intel CPU detected. Skipping configuration."
    return 0
  fi

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
  git config --global user.name "rodhfr"
  echo "Git username set to: rodhfr"

  git config --global user.email "souzafrodolfo@gmail.com"
  echo "Git email set to: souzafrodolfo@gmail.com"

  echo "Setting default branch to main..."
  git config --global init.defaultBranch main
  echo "Ok."
}

sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

repos=(
  alternateved/keyd
  lizardbyte/beta
)

for repo in "${repos[@]}"; do
  sudo dnf copr -y enable "$repo" || echo "WARNING: failed to install repository $repo"
done

sudo dnf group upgrade core -y
sudo dnf4 group install core -y
sudo dnf -y update

sudo dnf4 group install multimedia -y
sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing                                                   # Switch to full FFMPEG.
sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video                                                                # Installs useful Sound and Video complementary packages.

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

packages=(
  fzf
  fuse-libs
  waybar
  swaybg
  pipx
  steam
  rclone
  fuzzel
  sway
  alacritty
  neovim
  unzip
  p7zip
  p7zip-plugins
  keyd
  sed
  unrar
  mpv
  go
  tldr
  zoxide
  nautilus-python
  git
  sunshine
  fish
)

pypackages=(
  flatgrep
  autotiling
)

for pkg in "${packages[@]}"; do
  sudo dnf install -y "$pkg" || echo "WARNING: failed to install $pkg"
done

for pypkg in "${pypackages[@]}"; do
  pipx install -y "$pypkg" || echo "WARNING: failed to install $pypkg"
done

flatpak install -y --user flathub \
  com.discordapp.Discord \
  com.github.huluti.Coulr \
  com.moonlight_stream.Moonlight \
  com.obsproject.Studio \
  com.obsproject.Studio.Plugin.BackgroundRemoval \
  com.adamcake.Bolt \
  com.obsproject.Studio.Plugin.DroidCam \
  com.obsproject.Studio.Plugin.GStreamerVaapi \
  com.obsproject.Studio.Plugin.Gstreamer \
  com.obsproject.Studio.Plugin.InputOverlay \
  com.google.Chrome \
  com.obsproject.Studio.Plugin.OBSVkCapture \
  com.obsproject.Studio.Plugin.WaylandHotkeys \
  com.spotify.Client \
  com.stremio.Stremio \
  dev.diegovsky.Riff \
  net.retrodeck.retrodeck \
  io.github.kolunmi.Bazaar \
  org.audacityteam.Audacity \
  org.audacityteam.Audacity.Codecs \
  org.gnome.Boxes \
  org.gnome.Boxes.Extension.OsinfoDb \
  org.gnome.gitlab.somas.Apostrophe \
  org.localsend.localsend_app

# curl installs
curl -sSL https://starship.rs/install.sh | sh -s -- -y
curl -sSL https://astral.sh/uv/install.sh | sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | NONINTERACTIVE=1 bash
# this is a nvm replacement fmn
curl -fsSL https://fnm.vercel.app/install | bash

# brew installs
brew install gcc

# cargo install
cargo install eza

# setup shell
sudo chsh -s /usr/bin/fish "$USER"
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

# Enable user systemd services (managed by dotfiles_secret, not stow)
#systemctl --user enable rclone-station.service
systemctl --user enable sunshine.service

# keyd exec
bash "$HOME/dotfiles/.config/keyd/update.sh"

swaymsg reload

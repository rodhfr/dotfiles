#!/usr/bin/env bash

# Ensure proper PATH for Sway hotkeys / Wayland
export PATH=/usr/local/bin:/usr/bin:/bin:/home/rodhfr/.local/bin
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Prompt for URL
URL=$(/usr/bin/fuzzel -D yes -d --placeholder="YouTube Flac Downloader")

# Exit if empty
if [[ -z "$URL" ]]; then
  /usr/bin/notify-send "Error" "No URL provided"
  exit
fi

# Destination folder
DEST=~/Music
mkdir -p "$DEST"

# Terminal emulator to use (change to your preferred terminal)
TERMINAL="alacritty" # or "alacritty" / "kitty" / "gnome-terminal"

# Build yt-dlp command string
CMD="yt-dlp -P \"$DEST\" -x --audio-format flac \"$URL\"; echo; read -n1 -s -r -p 'Press any key to exit...'"

# Spawn terminal with yt-dlp
$TERMINAL -e sh -c "$CMD" &
/usr/bin/notify-send "Download concluído" "$URL"

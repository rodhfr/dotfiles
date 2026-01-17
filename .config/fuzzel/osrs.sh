#!/bin/bash

input=$(fuzzel --width 60 -D yes -d --placeholder="Folder in ~/Music and URL, e.g.: jazz https://youtu.be/...")
[ -z "$input" ] && exit 0

# primeiro campo = path
dest=$(printf '%s\n' "$input" | awk '{print $1}')

# resto da linha = URL
url=$(printf '%s\n' "$input" | cut -d' ' -f2-)

# expande ~ corretamente
dest=$(eval echo "$dest")

# valida URL
if ! printf '%s\n' "$url" | grep -qE '^https?://'; then
  notify-send "URL inválida" "$url"
  exit 1
fi

yt-dlp -P "~/Music/$dest" -x --audio-format flac "$url"

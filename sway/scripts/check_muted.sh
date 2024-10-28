if wpctl get-mute @DEFAULT_AUDIO_SINK@ | grep -q "Muted"; then
    DefaultSinkMuted = 1
else
    DefaultSinkMuted = 0
fi


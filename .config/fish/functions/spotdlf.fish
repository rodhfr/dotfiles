function spotdlf
    set BASE "$HOME/Music"
    set URL ""
    set DEST ""

    switch (count $argv)
        case 1
            set URL $argv[1]
            set DEST "$BASE"
        case 2
            set DEST "$BASE/$argv[1]"
            set URL $argv[2]
        case '*'
            echo "Usage:"
            echo "  spotdlf <URL>"
            echo "  spotdlf <folder> <URL>"
            return 1
    end

    # Ensure destination exists
    if not test -d "$DEST"
        mkdir -p "$DEST"
    end

    spotdl --output "$DEST" "$URL" --lyrics synced genius musixmatch azlyrics --generate-lrc
    notify-send -t 2000 -i audio-x-generic Spotdlf "Task completed."
end

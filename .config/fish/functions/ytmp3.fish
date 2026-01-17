# function ytmp3
#     # Initialize defaults
#     set URL ""
#     set DEST "$HOME/Music"
#     set SUBFOLDER ""
#
#     # Parse arguments
#     set i 1
#     while test $i -le (count $argv)
#         switch $argv[$i]
#             case --dir_name -d
#                 # Take next argument as subfolder name
#                 set SUBFOLDER $argv[(math $i + 1)]
#                 set i (math $i + 1) # skip the subfolder argument
#             case '*'
#                 # If URL not set yet, treat this as URL
#                 if test -z "$URL"
#                     set URL $argv[$i]
#                 else
#                     echo "Unknown argument: $argv[$i]"
#                     return 1
#                 end
#         end
#         set i (math $i + 1)
#     end
#
#     # Check URL
#     if test -z "$URL"
#         echo "Usage: ytflac <URL> [--dir_name NAME | -d NAME]"
#         echo "Default Destination: $DEST"
#         return 1
#     end
#
#     # Append subfolder if provided
#     if test -n "$SUBFOLDER"
#         set DEST "$DEST/$SUBFOLDER"
#     end
#
#     # Make sure destination exists
#     if not test -d "$DEST"
#         mkdir -p "$DEST"
#     end
#
#     # Download audio as FLAC
#     #yt-dlp -P "$DEST" -x --audio-format flac --embed-thumbnail --add-metadata "$URL"
#     yt-dlp -P "$DEST" -x --audio-format mp3 --embed-thumbnail --add-metadata "$URL"
#
#     echo
#     echo "Download complete. Press Enter to exit..."
#     notify-send "YouTube FLAC Download" "✅Download completed in $DEST"
#     echo
#     exit
#     #read
# end
#

function ytmp3
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
            echo "  ytmp3 <URL>"
            echo "  ytmp3 <folder> <URL>"
            return 1
    end

    # Ensure destination exists
    if not test -d "$DEST"
        mkdir -p "$DEST"
    end

    # Download as mp3
    yt-dlp -P "$DEST" -x --audio-format mp3 --embed-thumbnail --add-metadata "$URL"

    notify-send "YouTube MP3 Download" "✅ Download completed in $DEST"
end

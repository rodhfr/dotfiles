function nyaa
    set QUERY (string join " " $argv)
    echo $QUERY
    set URL 'https://nyaa.si/?q='$QUERY'&f=0&c=0_0&s=seeders&o=desc'
    xdg-open $URL >/dev/null 2>&1 &
    disown
    notify-send -t 2000 -i dialog-information fish - Nyaa "Nyaa Search Query"
    exit
    kill -9 $PPID
end

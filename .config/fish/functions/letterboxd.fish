set QUERY_TITLE Letterboxd
set QUERY_DESCRIPTION "Search Complete"

function letterboxd
    set QUERY (string join "_" $argv)

    set redirectURL (curl -Ls -o /dev/null -w '%{url_effective}\n' 'https://www.google.com/search?q='$QUERY'%20'$QUERY_TITLE'&btnI=I%27m+Feeling+Lucky')
    set URL (echo $redirectURL | string replace -r '.*q=(https[^&]*).*' '$1')

    # echo "URL:"
    # echo "$URL"
    xdg-open "$URL" >/dev/null 2>&1 &
    notify-send -t 2000 -i dialog-information "$QUERY_TITLE" "$QUERY_DESCRIPTION"

    # exit
    # kill -9 $PPID

end

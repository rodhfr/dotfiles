set ntf_send_title Myanimelist
set ntf_send_description "Search Complete"
function myanimelist
    set QUERY (string join "_" $argv)

    set redirectURL (curl -Ls -o /dev/null -w '%{url_effective}\n' 'https://www.google.com/search?q='$QUERY'%20myanimelist&btnI=I%27m+Feeling+Lucky')
    set URL (echo $redirectURL | string replace -r '.*q=(https[^&]*).*' '$1')

    # echo "URL:"
    # echo "$URL"
    xdg-open "$URL" >/dev/null 2>&1 &
    notify-send -t 2000 -i dialog-information "$ntf_send_title" "$ntf_send_description"

    # exit
    # kill -9 $PPID

end

function headless_off
    set displays_string ""
    for output in (swaymsg -t get_outputs | jq -r '.[] | select(.name|startswith("HEADLESS")) | .name')
        swaymsg output $output unplug
        set displays_string "$displays_string $output"
    end
    echo "Headless Display Disabled"
    echo $displays_string
    notify-send Headless "Display Disabled: $displays_string"
end

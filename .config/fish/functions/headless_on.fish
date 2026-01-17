function headless_on
    swaymsg create_output HEADLESS-1
    swaymsg output HEADLESS-1 enable resolution 1600x720 scale 1.5
    echo "Headless Display Enabled"
    notify-send Headless "Display Enabled"
end

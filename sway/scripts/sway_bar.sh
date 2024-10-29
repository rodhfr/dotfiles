# Change this according to your device
################
# Variables
################

# Keyboard input name
#keyboard_input_name="1:1:AT_Translated_Set_2_keyboard"

# Date and time
date_and_week=$(date "+%Y/%m/%d (w%-V)")
current_time=$(date "+%H:%M")

#############
# Commands
#############



if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q -i "Muted"; then
    audio_active='🔇'
  else
        audio_active='🔊'
        fi


audio_volume=$(pamixer --sink `pactl list sinks short | grep RUNNING | awk '{print $1}'` --get-volume)




# Audio and multimedia
media_artist=$(playerctl metadata artist)
media_song=$(playerctl metadata title)
player_status=$(playerctl status)

# Network
network=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
# interface_easyname grabs the "old" interface name before systemd renamed it
interface_easyname=$(dmesg | grep $network | grep renamed | awk 'NF>1{print $NF}')
ping=$(ping -c 1 www.google.es | tail -1| awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)

# Others
language=$(swaymsg -r -t get_inputs | awk '/1:1:AT_Translated_Set_2_keyboard/;/xkb_active_layout_name/' | grep -A1 '\b1:1:AT_Translated_Set_2_keyboard\b' | grep "xkb_active_layout_name" | awk -F '"' '{print $4}')
loadavg_5min=$(cat /proc/loadavg | awk -F ' ' '{print $2}')

# Battery or charger
battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "percentage" | awk '{print $2}' | tr -d '%') # Remove the % from battery_charge
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')
if [ "$battery_status" = "discharging" ]; then
    battery_pluggedin='🔋'

    # Check if battery is low
    if [ "$battery_charge" -lt 25 ]; then # -lt means less than
        battery_alert='Low Battery ⚠️'
    fi
else
    battery_pluggedin='⚡'
fi


if ! [ $network ]
then
   network_active="⛔"
else
   network_active="⇆"
fi

if [ $player_status = "Playing" ]
then
    song_status='▶'
elif [ $player_status = "Paused" ]
then
    song_status='⏸'
else
    song_status='⏹'
fi

tempo=$(echo $(curl -s "https://wttr.in/Joao_Pessoa?0&T&Q&format=2"))

echo "$tempo - 🎧 $song_status $media_artist - $media_song | ⌨ $language | $network_active $interface_easyname ($ping ms) | 🚀 $loadavg_5min | $audio_active $audio_volume% | "$battery_alert" $battery_pluggedin $battery_charge | $date_and_week 🕘 $current_time"

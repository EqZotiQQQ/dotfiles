run-unique compton
feh --bg-scale ~/Pictures/Wallpaper/mountains_lake_tops_top_view_119133_3840x2160.jpg





kilall -q polybar
while pgrep -u $UID -x polybar >dev/null; do sleep 1; done
polybar -c ~/.config/polybar/config.ini main &

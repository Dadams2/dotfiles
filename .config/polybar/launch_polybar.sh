DIR="$HOME/.config/polybar"


# kill already running bars
killall -q polybar
#wait till bars are actually killed
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#start new bars
for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar --reload -q mybar -c "$DIR"/config &
done

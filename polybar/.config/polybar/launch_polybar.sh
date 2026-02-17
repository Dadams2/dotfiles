DIR="$HOME/.config/polybar"


# kill already running bars
killall -q polybar
#wait till bars are actually killed
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#start new bars
# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar --reload -q -c "$DIR"/bars/default.ini default &
# done

while IFS= read -r line;do
    mon=$(cut -d":" -f1<<<"$line")
    res=$(echo $line | cut -d":" -f2 | cut -d"+" -f1)
    if [[ "$res" == " 1080x1920" ]]; then
        MONITOR=$mon polybar --reload -q -c "$DIR"/bars/vertical.ini default &
    elif [[ "$res" == " 5120x1440" ]]; then
        MONITOR=$mon polybar --reload -q -c "$DIR"/bars/ultrawide.ini ultrawide &
    else
        MONITOR=$mon polybar --reload -q -c "$DIR"/bars/secondary.ini default &
    fi
done < <(polybar --list-monitors)

# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar --reload -q main -c "$DIR"/float/config.ini &
# done

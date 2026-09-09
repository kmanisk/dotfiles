#!/usr/bin/env sh

STATE_FILE="$HOME/.config/polybar/bar_state"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# Launch polybar detached
if type "xrandr" >/dev/null 2>&1; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload example </dev/null >/dev/null 2>&1 &
  done
else
  polybar --reload example </dev/null >/dev/null 2>&1 &
fi

# Check saved state: if previously hidden and not forced show, hide bar
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "hidden" ] && [ "$1" != "--show" ]; then
    sleep 0.3
    polybar-msg cmd hide >/dev/null 2>&1
fi

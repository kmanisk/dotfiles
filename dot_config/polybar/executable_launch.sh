#!/usr/bin/env sh

STATE_FILE="$HOME/.config/polybar/bar_state"

# Terminate already running bar instances cleanly
killall -q polybar
pkill -9 -x polybar 2>/dev/null

# Wait until all processes have actually shut down
while pgrep -u $UID -x polybar >/dev/null 2>&1; do
    sleep 0.1
done

# Primary display detection (avoid spawning multiple stacked bars)
PRIMARY_MON=$(xrandr --query 2>/dev/null | grep " connected primary" | cut -d" " -f1)
if [ -z "$PRIMARY_MON" ]; then
    PRIMARY_MON=$(xrandr --query 2>/dev/null | grep " connected" | cut -d" " -f1 | head -n1)
fi

# Launch single polybar instance
if [ -n "$PRIMARY_MON" ]; then
    MONITOR="$PRIMARY_MON" polybar --reload example </dev/null >/dev/null 2>&1 &
else
    polybar --reload example </dev/null >/dev/null 2>&1 &
fi

# Check saved state: if previously hidden and not forced show, hide bar
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "hidden" ] && [ "$1" != "--show" ]; then
    sleep 0.2
    polybar-msg cmd hide >/dev/null 2>&1
fi

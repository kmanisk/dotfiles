#!/usr/bin/env bash

# Matugen injects these dynamically. Zero subshells or forks used.
c_1="#a3c9fe"
c_2="#bbc7db"
c_3="#d8bde3"
c_4="#1d4875"
c_5="#3c4858"

# U+25CF (Black Circle) with Pango color spans
dots="<span color='${c_1}'>●</span> <span color='${c_2}'>●</span> <span color='${c_3}'>●</span> <span color='${c_4}'>●</span> <span color='${c_5}'>●</span>"

# Sending as Body (3rd positional argument) because Summary does not parse markup.
notify-send -a "matugen-theme" -h string:x-canonical-private-synchronous:sys-theme "theme" "${dots}"

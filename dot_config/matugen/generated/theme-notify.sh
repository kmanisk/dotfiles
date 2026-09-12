#!/usr/bin/env bash

# Matugen injects these dynamically. Zero subshells or forks used.
c_1="#82d3e2"
c_2="#b1cbd0"
c_3="#bbc5ea"
c_4="#004e59"
c_5="#334b4f"

# U+25CF (Black Circle) with Pango color spans
dots="<span color='${c_1}'>●</span> <span color='${c_2}'>●</span> <span color='${c_3}'>●</span> <span color='${c_4}'>●</span> <span color='${c_5}'>●</span>"

# Sending as Body (3rd positional argument) because Summary does not parse markup.
notify-send -a "matugen-theme" -h string:x-canonical-private-synchronous:sys-theme "theme" "${dots}"

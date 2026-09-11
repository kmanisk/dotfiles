#!/usr/bin/env bash

# Matugen injects these dynamically. Zero subshells or forks used.
c_1="{{colors.primary.default.hex}}"
c_2="{{colors.secondary.default.hex}}"
c_3="{{colors.tertiary.default.hex}}"
c_4="{{colors.primary_container.default.hex}}"
c_5="{{colors.secondary_container.default.hex}}"

# U+25CF (Black Circle) with Pango color spans
dots="<span color='${c_1}'>●</span> <span color='${c_2}'>●</span> <span color='${c_3}'>●</span> <span color='${c_4}'>●</span> <span color='${c_5}'>●</span>"

# Sending as Body (3rd positional argument) because Summary does not parse markup.
notify-send -a "matugen-theme" -h string:x-canonical-private-synchronous:sys-theme "theme" "${dots}"

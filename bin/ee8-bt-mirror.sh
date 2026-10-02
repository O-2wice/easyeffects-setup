#!/usr/bin/env bash
# ee8-bt-mirror.sh: EasyEffects 8 plays to the default speaker (it follows it by
# itself, and loads that speaker's preset via its own Autoload list). This only
# adds the multi-speaker part: copy the processed (post-EQ) sound to EVERY
# connected Bluetooth speaker, so two BT speakers play together with the EQ.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
EE_OUT="ee_soe_output_level"
link_all() {
    pw-link -o 2>/dev/null | grep -q "^${EE_OUT}:output_FL" || return 0
    local bts; bts=$(pactl list short sinks | awk '/bluez_output\./ {print $2}')
    [ "$(wc -l <<<"$bts")" -ge 2 ] || return 0      # one speaker: EasyEffects already handles it
    while read -r s; do
        for ch in FL FR; do pw-link "${EE_OUT}:output_${ch}" "${s}:playback_${ch}" 2>/dev/null; done
    done <<<"$bts"
}
( while true; do link_all; sleep 3; done ) &
stdbuf -oL pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in *"on sink"*) sleep 1; link_all ;; esac
done

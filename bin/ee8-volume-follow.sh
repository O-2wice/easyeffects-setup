#!/usr/bin/env bash
# ee8-volume-follow.sh: the volume keys control the default speaker directly
# (a real device now, not the EasyEffects sink). When a second Bluetooth speaker
# is mirrored, shift it by the same steps and mirror mute, so both stay in step.
# Its own level, set in pavucontrol, is kept between key presses.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pct() { pactl get-sink-volume "$1" 2>/dev/null | grep -oP '\d+(?=%)' | head -1; }
mtd() { pactl get-sink-mute   "$1" 2>/dev/null | grep -q yes && echo 1 || echo 0; }
master=""; last=""; lastm=""
apply() {
    local m v mm s cur new
    m=$(pactl get-default-sink 2>/dev/null)
    case "$m" in bluez_output.*) ;; *) master=""; return ;; esac
    v=$(pct "$m"); mm=$(mtd "$m"); [ -z "$v" ] && return
    if [ "$m" != "$master" ]; then master=$m; last=$v; lastm=$mm; return; fi
    if [ "$v" != "$last" ]; then
        while read -r s; do
            [ "$s" = "$m" ] && continue
            cur=$(pct "$s"); [ -z "$cur" ] && continue
            new=$(( cur + v - last )); (( new > 100 )) && new=100; (( new < 0 )) && new=0
            pactl set-sink-volume "$s" "${new}%"
        done < <(pactl list short sinks | awk '/bluez_output\./ {print $2}')
        last=$v
    fi
    if [ "$mm" != "$lastm" ]; then
        while read -r s; do [ "$s" = "$m" ] || pactl set-sink-mute "$s" "$mm"; done < <(pactl list short sinks | awk '/bluez_output\./ {print $2}')
        lastm=$mm
    fi
}
apply
while true; do
    read -t 3 -r line; rc=$?
    if [ $rc -eq 0 ]; then case "$line" in *"on sink"*|*"on server"*) apply ;; esac
    elif [ $rc -gt 128 ]; then apply
    else break; fi
done < <(stdbuf -oL pactl subscribe 2>/dev/null)

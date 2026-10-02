#!/usr/bin/env bash
# ee8-keep-effects.sh: keep the effects you added in the GUI when EasyEffects
# restarts on the same speaker.
#
# On startup EasyEffects restores the effects chain it last saved, then Autoload
# replaces it with the speaker's preset. That is right after a speaker change,
# but after a restart on the SAME speaker (a crash or a force-kill) it throws
# away everything added on top of the preset.
#
#   pre   (ExecStartPre)  if the default speaker is the one EasyEffects last
#         used, point that speaker's Autoload entry at a preset that does not
#         exist. The startup autoload then finds an entry (so no fallback) but
#         no preset file, and EasyEffects leaves the chain alone.
#   post  (ExecStartPost) once startup is over, put the real entry back.
#   restore (ExecStopPost) put the real entry back right away.

EE=~/.var/app/com.github.wwmm.easyeffects
DB=${EE8_DB:-$EE/config/easyeffects/db/easyeffectsrc}
AUTO=${EE8_AUTO:-$EE/data/easyeffects/autoload/output}
STASH=${EE8_STASH:-$HOME/.local/state/ee8-keep-effects}
KEEP_NAME="_keeping_your_last_effects_"

restore() {
    local f
    for f in "$STASH"/*.json; do
        [ -e "$f" ] && mv -f "$f" "$AUTO/"
    done
}

last_device() {
    awk '/^\[StreamOutputs\]/ {s=1; next} /^\[/ {s=0} s && /^outputDevice=/ {print substr($0, 14)}' "$DB"
}

pre() {
    restore   # leftovers from a start that never reached "post"
    local last cur f tmp
    last=$(last_device)
    cur=${EE8_CUR:-$(timeout 5 pactl get-default-sink 2>/dev/null)}
    if [ -z "$last" ] || [ "$last" != "$cur" ]; then
        logger -t ee8-keep-effects "speaker changed ($last -> $cur): normal autoload"
        return 0
    fi
    mkdir -p "$STASH"
    for f in "$AUTO/${cur//\//_}:"*.json; do
        [ -e "$f" ] || continue
        cp -p "$f" "$STASH/"
        tmp=$(mktemp "$AUTO/.keep.XXXXXX")
        /usr/bin/python3 - "$f" "$KEEP_NAME" > "$tmp" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
d["preset-name"] = sys.argv[2]
print(json.dumps(d, indent=4))
EOF
        mv -f "$tmp" "$f"
    done
    logger -t ee8-keep-effects "same speaker ($cur): keeping the last effects chain"
}

post() {
    # Autoload runs about 2s after EasyEffects creates its sink; wait well past it.
    local i
    for i in $(seq 1 30); do
        pactl list short sinks 2>/dev/null | grep -q easyeffects_sink && break
        sleep 1
    done
    sleep 8
    restore
}

case "$1" in
    pre) pre ;;
    post) post ;;
    restore) restore ;;
    *) echo "usage: $0 pre|post|restore" >&2; exit 2 ;;
esac
exit 0

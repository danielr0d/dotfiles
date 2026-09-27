#!/usr/bin/env bash
# Renders a single workspace circle for a custom waybar module.
# Replaces hyprland/workspaces, whose click handler still sends the pre-Lua
# dispatch syntax that Hyprland 0.56+ rejects.

ws="$1"
sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

render() {
    active=$(hyprctl monitors -j | jq --arg out "$WAYBAR_OUTPUT_NAME" \
        '.[] | select(.name == $out) | .activeWorkspace.id')
    windows=$(hyprctl workspaces -j | jq --argjson ws "$ws" \
        '[.[] | select(.id == $ws)][0].windows // 0')

    if [ "$active" = "$ws" ]; then
        icon=$'' class=active
    elif [ "$windows" -gt 0 ]; then
        icon=$'' class=occupied
    else
        icon=$'' class=empty
    fi

    jq -cn --arg text "<span size='larger'>$icon</span>" --arg class "$class" \
        '{text: $text, class: $class}'
}

render
socat -U - "UNIX-CONNECT:$sock" | while read -r event; do
    case "$event" in
        workspace*|focusedmon*|openwindow*|closewindow*|movewindow*|createworkspace*|destroyworkspace*)
            render ;;
    esac
done

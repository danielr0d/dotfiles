#!/bin/sh
player_status=$(playerctl status 2>/dev/null)
metadata_url=$(playerctl metadata --format '{{xesam:url}}' 2>/dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
  title=$(playerctl metadata title)

  if echo "$metadata_url" | grep -q "youtube"; then
    if [ "$player_status" = "Playing" ]; then
      echo "$title"
    else
      echo " $title"
    fi
  else
    artist=$(playerctl metadata artist)
    if [ "$player_status" = "Playing" ]; then
      echo "$artist - $title"
    else
      echo " $artist - $title"
    fi
  fi
fi

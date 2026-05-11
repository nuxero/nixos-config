#!/usr/bin/env bash
# launch-or-focus.sh — Launch an app or focus it if already running.
# Usage: launch-or-focus.sh <class-name>
#
# Uses hyprctl to find a window matching the class name across all workspaces.
# If found, focuses it. If not, launches it.

APP_CLASS="$1"

if [ -z "$APP_CLASS" ]; then
  echo "Usage: $0 <app-class>"
  exit 1
fi

# Try to find a window with matching class (case-insensitive)
WINDOW_ADDR=$(hyprctl clients -j | jq -r \
  --arg class "$APP_CLASS" \
  '[.[] | select(.class | ascii_downcase | contains($class | ascii_downcase))] | first | .address // empty')

if [ -n "$WINDOW_ADDR" ]; then
  # Focus the existing window
  hyprctl dispatch focuswindow "address:${WINDOW_ADDR}"
else
  # Launch the application
  hyprctl dispatch exec "$APP_CLASS"
fi

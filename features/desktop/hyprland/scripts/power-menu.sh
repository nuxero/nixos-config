#!/usr/bin/env bash
# power-menu.sh — Rofi-based power menu for shutdown/reboot/logout/lock/suspend

OPTIONS="  Lock\n  Suspend\n  Logout\n  Reboot\n  Shutdown"

CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 250px;}')

case "$CHOSEN" in
  *Lock)      hyprlock ;;
  *Suspend)   systemctl suspend ;;
  *Logout)    hyprctl dispatch exit ;;
  *Reboot)    systemctl reboot ;;
  *Shutdown)  systemctl poweroff ;;
esac

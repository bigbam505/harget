#!/bin/bash

LOG=/var/log/harget/viewer/xloader.log

echo "Disabling screen power savings..." > $LOG

xset s off          # Don't activate screensaver
xset -dpms          # Disable DPMS (Energy Star) features
xset s noblank      # Don't blank the video device

echo "Launching infinite loop..." >> $LOG
while true; do
  # Clean up in case of an unclean exit
  echo "Cleaning up..." >> $LOG
  killall uzbl-core
  rm -f /tmp/uzbl_*

  # Launch the viewer
  python ~/harget/viewer.py ~/harget/service.yaml >> $LOG 2>&1
done

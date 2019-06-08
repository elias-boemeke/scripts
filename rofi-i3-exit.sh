#! /bin/sh

op=`echo "Shutdown\nReboot\nExit i3" | rofi -dmenu -l 3 -i -p "Select Option"`
if [ "$op" = "Shutdown" ]; then
  poweroff
elif [ "$op" = "Reboot" ]; then
  reboot
elif [ "$op" = "Exit i3" ]; then
  i3-msg 'exit'
fi


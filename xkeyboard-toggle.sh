#! /bin/sh


enablenotifications=0

layout=`setxkbmap -print -verbose 10 | awk '/^layout:/ { print $2 }'`

if [ "$layout" = "de" ]; then
  setxkbmap -model pc105 -layout ru
  [ "$enablenotifications" != 0 ] && notify-send "Keyboard Layout" "switched to ru"
else
  setxkbmap -model pc105 -layout de -variant nodeadkeys
  [ "$enablenotifications" != 0 ] && notify-send "Keyboard Layout" "switched to de"
fi


#! /bin/sh


enablenotifications=0

layout=`setxkbmap -print -verbose 10 | awk '/^layout:/ { print $2 }'`

lay="`printf "%s\n%s\n" "de" "ru" | rofi -dmenu -p "select keyboardlayout"`"

if [ "$lay" = "de" ]; then
  setxkbmap -model pc105 -layout de -variant nodeadkeys
  [ "$enablenotifications" != 0 ] && notify-send "Keyboard Layout" "switched to de"

elif [ "$lay" = "ru" ]; then
  setxkbmap -model pc105 -layout ru
  [ "$enablenotifications" != 0 ] && notify-send "Keyboard Layout" "switched to ru"

elif [ -z "$lay" ]; then
  exit 0

else
  notify-send "Keyboard Layout" "Unknown keyboard layout '$lay'"
fi


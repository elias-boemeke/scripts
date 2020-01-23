#! /bin/sh

url=`xclip -o -selection primary`
mpv --player-operation-mode=pseudo-gui "$url"
if [ "$?" != 0 ]; then
  notify-send "mpv" "unable to play '$url'"
fi

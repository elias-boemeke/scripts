#! /bin/sh

if [ "$1" = bg ]; then
  $0 &
  disown $!
  exit
fi

DIR="/media/wdo/multimedia/audio/music"
SONG=`find "$DIR" -type f | rofi -dmenu -i -p "play"`
[ -z "$SONG" ] && exit
printf "playing: \e[4m%s\e[0m\n" "$SONG"
termite -e "mpv \"$SONG\""


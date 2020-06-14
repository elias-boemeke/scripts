#! /bin/sh

VOL=60
DIR="/media/wdo/multimedia/audio/music"
SONG=`find "$DIR" -type f | fzy -l $(($(tput lines)-2))`
[ -z "$SONG" ] && exit
printf "playing: \e[4m%s\e[0m\n" "$SONG"
mpv --volume=$VOL "$SONG"


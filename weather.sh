#! /bin/sh

iface="enp3s0"
emoji=""

file="/tmp/custom/weather/wttr.png"
dir=`expr "$file" : '\(.*/\)'`

if [ "$#" -eq 0 ]; then
  exit 1
fi

mode="$1"

if [ "$mode" = "bar" ]; then
  if [ -z `grep up /sys/class/net/$iface/operstate` ]; then
    printf "$emoji"
    exit 0
  fi

  printf "%s %s\n" "$emoji" "`curl -s 'wttr.in/?format=%C+%t'`"

elif [ "$mode" = "simple" ]; then
  curl -s 'wttr.in/?0q'

elif [ "$mode" = "png" ]; then
  [ ! -d "$dir" ] && mkdir -p "$dir"
  curl -s 'wttr.in/_q.png' > "$file"
  feh "$file"

else
  echo "unsupported mode '$mode'"
  exit 1

fi

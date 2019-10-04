#! /bin/sh

emoji=""

if [ "$#" -eq 0 ]; then
  echo "Usage: weather.sh mode"
  echo "supported modes: bar simple full png"
  exit 1
fi

mode="$1"

if [ -z "`ip r | perl -ne '/^default via \d+(\.\d+){3} dev / && print'`" ]; then
  printf "$emoji off"
  exit 0
fi

if [ "$mode" = "bar" ]; then
  curl -s 'wttr.in/?format=%c+%t'

elif [ "$mode" = "simple" ]; then
  curl -s 'wttr.in/?0q'

elif [ "$mode" = "full" ]; then
  curl -s 'wttr.in/?qF'

elif [ "$mode" = "png" ]; then
  curl -s 'wttr.in/_qpF.png' | feh -

else
  echo "unsupported mode '$mode'"
  exit 1

fi

#! /bin/sh

emoji=""
pngfile="/tmp/custom/wttr.in_png"

if [ "$#" -eq 0 ]; then
  printf "Usage: weather.sh <mode>\n"
  printf "supported modes: bar simple full png\n"
  exit 1
fi

mode="$1"

if [ `pgrep openvpn` ]; then
  if [ "$mode" = png ]; then
    notify-send "weather.sh" "Weather is disabled when VPN is active"
  else
    printf "🌴"
  fi
  exit 0
fi

if [ -z "`ip r | perl -ne '/^default via \d+(\.\d+){3} dev / && print'`" ]; then
  printf "$emoji offline"
  exit 0
fi

OUTPUT=
if [ "$mode" = "bar" ]; then
  OUTPUT=`curl -s 'wttr.in/?format=%c+%t'`

elif [ "$mode" = "simple" ]; then
  OUTPUT=`curl -s 'wttr.in/?0q'`

elif [ "$mode" = "full" ]; then
  OUTPUT=`curl -s 'wttr.in/?qF'`

elif [ "$mode" = "png" ]; then
  [ ! -d "/tmp/custom" ] && mkdir "/tmp/custom"
  curl -s 'wttr.in/Kassel_qpF.png' > "$pngfile"

else
  printf "unsupported mode '$mode'"
  exit 1

fi

if [ "$?" != 0 ]; then
  printf "$emoji error"
  exit 1
fi

# match illformed answers
if [ ! -z "`echo \"$OUTPUT\" | grep '^Unknown location;'`" ]; then
  printf "$emoji error"
  exit 1
elif [ ! -z "`echo \"$OUTPUT\" | grep -i 'sorry'`" ]; then
  printf "$emoji no service"
  exit 1
fi

# display output or pipe to feh
if [ "$mode" = "png" ]; then
  feh "$pngfile"
  rm "$pngfile"
else
  printf "%s" "$OUTPUT"
fi


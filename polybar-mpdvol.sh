#! /bin/sh


# when mpd is online
# 'volume: 52%' [0]
# when mpd is offline
# 'mpd error: Connection refused' [1]

o="$(mpc vol)"
if [ "$?" != 0 ]; then
  # format offline
  echo " "
  exit 0
fi

vol=`expr "$o" : '[^[:digit:]]*\([[:digit:]]\+\)'`
# format online
echo "   $vol%"


#! /bin/sh


enablenotifications=0

displayError() {
  notify-send -u 'critical' "invalid use of script $0"
}

if [ "$#" != 1 ]; then
  displayError
  exit 1
fi

if [ "$1" = 'voldown' ]; then
  mpc volume -2
  polybar-msg hook mpdvol 1
  [ "$enablenotifications" != 0 ] && notify-send 'mpd' 'volume decreased by 2'

elif [ "$1" = 'volup' ]; then
  mpc volume +2
  polybar-msg hook mpdvol 1
  [ "$enablenotifications" != 0 ] && notify-send 'mpd' 'volume increased by 2'

elif [ "$1" = 'toggleplay' ]; then
  playing=`mpc | sed -n '/^\[playing\]/p'`
  pl='resumed'
  if [ ! -z "$playing" ]; then
    pl='stopped'
  fi
  mpc toggle
  [ "$enablenotifications" != 0 ] && notify-send 'mpd' "playback $pl"

else
  displayError
  exit 1
fi


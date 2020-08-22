#! /bin/sh


enablenotifications=0

displayError() {
  notify-send -u 'critical' "invalid use of script $0"
}

if [ "$#" != 1 ]; then
  displayError
  exit 1
fi

if [ "$1" = 'brightdec' ]; then
  xbacklight -dec 5
  polybar-msg hook backlight 1
  [ "$enablenotifications" != 0 ] && notify-send 'backlight' 'brightness decreased by 5'

elif [ "$1" = 'brightinc' ]; then
  xbacklight -inc 5
  polybar-msg hook backlight 1
  [ "$enablenotifications" != 0 ] && notify-send 'backlight' 'brightness increased by 5'

else
  displayError
  exit 1
fi


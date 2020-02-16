#! /bin/bash

# this script combines several ideas from different authors
# for references see:
# i3-lock(-color) man page
# post by u/GermainZ on reddit/unixporn
# https://github.com/xero/glitchlock

# the script has the following core ideas:
# - take a screenshot (s) of the current screen
# - (optional) apply a glitch effect to s
# - (optional) apply a blur effect to s
# - suspend the notification daemon (dunst)
# - pause mpd if playing
# - (optional) set appropriate display power management signaling options (dpms)
# - (optional) switch to workspace 1, so that password doesn't get accidentally into a wrong place
# - start i3-lock with the modified s
# - revert all changes back to their original state

# options:
# WARN longoptions not supported at the moment
# --glitch, -g     : glitchify the captured image 
# --blur, -b       : blur the captured image
# --workspace, -w  : switch to a safe workspace
# --icon, -i [pos] : position the 'locked' icon
# --no-dpms        : disable display power management signaling


DISPLAY_TIME=10

dir="/tmp/custom"
img_png="$dir/lock.png"
img_jpg="$dir/lock.jpg"

# glitch functions
datamosh() {
  file=$1
  fileSize=$(wc -c < "$file")
  headerSize=1000
  skip=$(shuf -i "$headerSize"-"$fileSize" -n 1)
  count=$(shuf -i 1-10 -n 1)
  for i in $(seq 1 $count); do
    byteStr=$byteStr'\x'$(shuf -i 0-255 -n 1)
  done   
  printf $byteStr | dd of="$file" bs=1 seek=$skip count=$count conv=notrunc &> /dev/null
}

glitch() {
  [ "$#" != 1 ] && echo "glitch called with invalid number of arguments" && exit 1
  file=$1
  steps=$(shuf -i 40-70 -n 1)
  for i in $(seq 1 $steps); do
    datamosh "$file"
  done
}

#######################################################################

parse() {
  OPTION_DPMS='1'

  i=0
  while getopts "gbwi:" opt; do
    case $opt in
      g) OPTION_GLITCH='1' ;;
      b) OPTION_BLUR='1' ;;
      w) OPTION_SWITCHWORKSPACE='1' ;;
      i) OPTION_ICONPOS="$OPTARG" ;;
      ?) echo "Failed to parse arguments..."; exit 1 ;;
    esac  
  done
}

#######################################################################

revert() {
  pkill -u $USER -USR2 dunst
  if [ "$MPD_ACTIVE" ]; then
    mpc -q play
  fi
  if [ "OPTION_DPMS" ]; then
    xset dpms 0 0 0
  fi
  [ -f "$img_png" ] && rm "$img_png"
  [ -f "$img_jpg" ] && rm "$img_jpg"
}

#######################################################################

# execute this before anything else
trap revert HUP INT TERM

# parse arguments
parse "$@"
# take screenshot and transform to jpg
[ ! -d "$dir" ] && mkdir -p "$dir"
scrot "$img_png"
if [ "$OPTION_GLITCH" ]; then
  convert "$img_png" "$img_jpg"
  glitch "$img_jpg"
  convert "$img_jpg" "$img_png" &> /dev/null
fi
if [ "$OPTION_BLUR" ]; then
  convert "$img_png" -blur 0x1 "$img_png"
fi
# draw the locked overlay into the image
if [ "$OPTION_ICONPOS" ]; then
  magick composite -geometry "$OPTION_ICONPOS" "/multimedia/pictures/system/locked.png" "$img_png" "$img_png"
fi

# Suspend dunst and lock, then resume dunst when unlocked.
pkill -u $USER -USR1 dunst
# pause mpd if playing
mpc | sed "2q;d" | grep -q '^\[playing\]'
if [ $? = 0 ]; then
  MPD_ACTIVE='y'
  mpc -q pause
fi
# set a 5 second cooldown for display
if [ "$OPTION_DPMS" ]; then
  xset +dpms dpms "$DISPLAY_TIME" "$DISPLAY_TIME" "$DISPLAY_TIME"
fi

# start i3-lock
if [ "$OPTION_SWITCHWORKSPACE" ]; then
  i3-msg workspace 1 &> /dev/null
fi

# simple lock params
PARAM=( --insidecolor=373445ff --ringcolor=ffffffff --line-uses-inside \
        --keyhlcolor=d23c3dff --bshlcolor=d23c3dff --separatorcolor=00000000 \
        --insidevercolor=fecf4dff --insidewrongcolor=d23c3dff \
        --ringvercolor=ffffffff --ringwrongcolor=ffffffff --indpos="x+86:y+1003" \
        --radius=15 --veriftext="" --wrongtext="" --noinputtext="")

# params of the original glitch script
#PARAM=( --bar-indicator --bar-position h --bar-direction 1 --redraw-thread -t "" \
#        --bar-step 50 --bar-width 250 --bar-base-width 50 --bar-max-height 100 \
#        --bar-periodic-step 50 --bar-color 00000077 --keyhlcolor 00666666 \
#        --ringvercolor cc87875f --wrongcolor ffff0000 \
#        --veriftext="" --wrongtext="" --noinputtext="" )

i3lock -n -i "$img_png" "${PARAM[@]}"

# revert changes
revert
true # get a nice return value


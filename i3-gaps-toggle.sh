#! /bin/sh


nothl="i3-toggle-gaps"
enablenotifications=0

file='/tmp/custom/i3/gaps'
dir=`expr "$file" : '\(.*/\)'`

IFS='
'

info=`i3-msg -t get_config | awk '/^gaps/ {print}'`

for line in $info; do
  if [ `expr "$line" : '.*outer'` != 0 ]; then
    d_outer=`expr "$line" : '[^[:digit:]]*\([[:digit:]]\+\)'`
  elif [ `expr "$line" : '.*inner'` != 0 ]; then
    d_inner=`expr "$line" : '[^[:digit:]]*\([[:digit:]]\+\)'`
  fi
done

# remember whether gaps are on or off
[ ! -f "$file" ] && mkdir -p "$dir" && printf "on" > "$file"
state=`cat "$file"`

if [ "$state" = "on" ]; then
  printf "off" > "$file"
  i3-msg -q "gaps outer all set 0"
  i3-msg -q "gaps inner all set 0"
  [ "$enablenotifications" != 0 ] && notify-send "$nothl" "gaps set to 0"

else
  printf "on" > "$file"
  i3-msg -q "gaps outer all set $d_outer"
  i3-msg -q "gaps inner all set $d_inner"
  [ "$enablenotifications" != 0 ] && notify-send "$nothl" "gaps reset to defaults"

fi


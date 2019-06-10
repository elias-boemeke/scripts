#! /bin/sh

# script to automatically mount and unmount drives
# supports also android devices


IFS='
'
# notify headline
nothl="rofi-mount"


run_mount() {
  # drives of type partition
  pdrives=`lsblk -npr -o "name,type,size,mountpoint" | awk '$2 == "part" && $4 == "" {printf "[P] %s (%s)\n", $1, $3}'`
  # drives detected by simple-mtpfs
  adrives=`simple-mtpfs -l 2> /dev/null`
  [ ! -z "$adrives" ] && adrives=`printf $adrives | awk '{printf "[A] %s\n", $0}'`
  drives=`printf "%s\n%s\n" $adrives $pdrives`

  # no mountables found
  if [ -z "$drives" ]; then
    notify-send "$nothl" "no mountable drives found"
    exit 0
  fi

  # select a drive to mount
  selected=`printf "%s\n" "$drives" | rofi -dmenu -p "Select a drive to mount"`
  [ -z "$selected" ] && exit 0
  mode=`expr "$selected" : '^.\(.\)'`

  # select a folder to mount to
  excl=`mount -l | awk '{print $3}'`
  prure="^\\("
  i=0
  for x in `printf "%s" "$excl"`; do
    if [ "$i" = 0 ]; then
      prure="${prure}$x"
      i=1
    else
      prure="${prure}\|$x"
    fi
  done
  prure="${prure}\\)\\($\|/.*$\\)"

  dir=`find "/mnt" "/media" "${HOME}/usermount" -regex "$prure" -prune -not -regex "$prure" 2> /dev/null | rofi -dmenu -p "select or enter mountpoint"`
  [ "`expr "$dir" : "$prure"`" != 0 ] && notify-send "$nothl" "directory '$dir' is part of another mount device" && exit 1
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    [ "$?" != 0 ] && sudo -A mkdir -p "$dir"
    [ "$?" != 0 ] && notify-send "$nothl" "unable to create directory '$dir'" && exit 1
    notify-send "$nothl" "directory '$dir' created"
  fi

  if [ "$mode" = "P" ]; then
    device=`printf "%s\n" "$selected" | awk '{printf $2}'`
    sudo -A mount "$device" "$dir"
    [ "$?" != 0 ] && notify-send "$nothl" "failed to mount '$device' to '$dir'" && exit 1
    # check if ownership change is necessary
    [ "`stat --format "%U:%G" "$dir"`" = "${USER}:users" ] || sudo -A chown -R "$USER:users" "$dir"
    # giving permission to user may fail
    # [ "$?" != 0 ] && notify-send "$nothl" "failed to give user permissions to '$dir'"
    notify-send "$nothl" "'$device' mounted to '$dir'"

  elif [ "$mode" = "A" ]; then
    device=`expr "$selected" : '^.\{4\}[[:digit:]]\+: \(.*\)'`
    devicenr=`expr "$selected" : '^.\{4\}\([[:digit:]]\+\):.*'`
    o=`simple-mtpfs --device "$devicenr" "$dir" 2>&1`
    [ "$?" != 0 ] && notify-send "$nothl" "unable to mount '$device', output: '$o'" && exit 1
    notify-send "$nothl" "'$device' mounted to '$dir'"

  fi
}

run_unmount() {
  # unmountables
  amps=`mount -l | awk '/simple-mtpfs/ {printf "[A] %s", $3}'`
  pmps=`lsblk -nrpo "name,type,size,mountpoint" | awk '$2 == "part" && $4 != "" && $4 !~ /^(\/|\/boot|\[SWAP\])$/ {printf "[P] %s %s (%s)\n", $4, $1, $3}'`
  mps=`printf "%s\n%s\n" $amps $pmps`

  # no unmountables found
  if [ -z "$mps" ]; then
    notify-send "$nothl" "no unmountable drives found"
    exit 0
  fi

  # select unmountable
  selected=`printf "%s\n" "$mps" | rofi -dmenu -p "Select a mountpoint to unmount"`
  [ -z "$selected" ] && exit 0
  mode=`expr "$selected" : '^.\(.\)'`

  if [ "$mode" = "P" ]; then
    ump=`printf "%s\n" "$selected" | awk '{print $2}'`
    sudo -A umount "$ump"
    [ "$?" != 0 ] && notify-send "$nothl" "unable to unmount device at '$ump'" && exit 1
    notify-send "$nothl" "device unmount from '$ump'"
    
  elif [ "$mode" = "A" ]; then
    ump=`expr "$selected" : '^.\{4\}\(.*\)'`
    fusermount -u "$ump"
    [ "$?" != 0 ] && notify-send "$nothl" "unable to unmount device at '$ump'" && exit 1
    notify-send "$nothl" "device unmounted from '$ump'"

  fi

}

# main
op=`printf "mount a drive or device\nunmount a drive or device" | rofi -dmenu -p "Select an operation"`
op=`expr "$op" : '^\([^ ]\+\)'`

if [ "$op" = "mount" ]; then
  run_mount
elif [ "$op" = "unmount" ]; then
  run_unmount
else
  [ ! -z "$op" ] && notify-send "$nothl" "invalid mounting operation '$op'"
fi

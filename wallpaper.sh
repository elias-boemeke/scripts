#! /bin/sh

# wallpaper sources
# unsplash: example https://source.unsplash.com/random/1920x1080
# loremflickr: example https://loremflickr.com/1920/1080/dog

function usage {
  echo -e "Usage: ./`basename $0` [-h] [-u MIN]"
  echo -e "no args:\tset random wallpaper from \$HOME/.local/share/wallpaper"
  echo -e "-h:\t\tshow usage"
  echo -e "-u MIN:\t\tloop that updates wallpaper every MIN minutes"
}

function setwallpaper {
  find $HOME/.local/share/wallpaper -type f | shuf -n 1 | xargs xwallpaper --zoom
}

optstring=":hu:"

while getopts $optstring opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    u)
      # check if $OPTARG is number
      if test -n $OPTARG && test "$OPTARG" -eq "$OPTARG" 2> /dev/null; then
          wait=$OPTARG
      else
          echo "./`basename $0`: Argument of option -u must be number" >&2 && exit 1
      fi

      while true; do
        sleep ${wait}m
        setwallpaper
      done
      ;;
    :)
      echo "./`basename $0`: Must supply an argument to -$OPTARG" >&2
      exit 1
      ;;
    ?)
      echo -e "Invalid option -$OPTARG\n"
      usage
      exit 2
      ;;
  esac
done

setwallpaper


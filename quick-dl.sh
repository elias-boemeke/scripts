#! /bin/sh

# download from primary selection

url=`xclip -o -selection primary`
stamp=`date "+%Y-%m-%d-%T"`
curl -s "$url" -o "$HOME/Downloads/$stamp.content"
RET="$?"
echo "$url" > "$HOME/Downloads/$stamp.url"

if [ "$RET" = 0 ]; then
  notify-send "curl" "finished downloading '$url'"
else
  notify-send "curl" "unable to download '$url'"
  [ -f "$HOME/Downloads/$stamp.content" ] && rm "$HOME/Downloads/$stamp.content"
  [ -f "$HOME/Downloads/$stamp.url" ] && rm "$HOME/Downloads/$stamp.url"
fi


#! /bin/sh

# <link rel="alternate" type="application/rss+xml" title="RSS" href="https://www.youtube.com/feeds/videos.xml?channel_id=...">

if [ $# != 1 ]; then
  echo "Usage: $0 <link-to-yt-channel>"
  exit 1
fi

curl -s "$1" | perl -ne '/channel_id=(.*?)"/ && print "$1\n"'


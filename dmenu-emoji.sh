#! /bin/sh

# The famous "get a menu of emojis to copy" script.

# Get user selection via dmenu from emoji file.
chosen=$(cut -d ';' -f1 ~/.local/share/emoji | dmenu -i -l 30 | sed "s/ .*//")

# Exit if none chosen.
[ -z "$chosen" ] && exit
# Copy Emoji to clipboard
echo "$chosen" | tr -d '\n' | xclip -selection clipboard


#! /bin/sh

grep "^bind" ${HOME}/.config/i3/config | rofi -dmenu -i -p "keybindings"


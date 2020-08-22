#! /bin/sh

cmds="\
🔒 lock		slock
🚪 leave dwm	kill -TERM $(pidof -s dwm)
♻ renew dwm	kill -HUP $(pidof -s dwm)
🐻 hibernate	${hib:-sudo -A systemctl suspend-then-hibernate}
🔃 reboot	${reb:-sudo -A reboot}
🖥 shutdown	${shut:-sudo -A shutdown -h now}"

choice="$(echo "$cmds" | cut -d'	' -f 1 | rofi -dmenu)" || exit 1

echo "$cmds" | grep "^$choice	" | cut -d '	' -f2-


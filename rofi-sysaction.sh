#! /bin/sh

#case "`readlink -f /sbin/init`" in
#  *runit*) hib="sudo -A zzz" ;;
#  *openrc*) reb="sudo -A openrc-shutdown -r"; shut="sudo -A openrc-shutdown -p" ;;
#esac



cmds="\
🔒 lock		slock
🚪 leave dwm	kill -TERM $(pidof -s dwm)
♻ renew dwm	kill -HUP $(pidof -s dwm)
🐻 hibernate	${hib:-sudo -A systemctl suspend-then-hibernate}
🔃 reboot	${reb:-sudo -A reboot}
🖥 shutdown	${shut:-sudo -A shutdown -h now}"

choice="$(echo "$cmds" | cut -d'	' -f 1 | rofi -dmenu -p 'Action')" || exit 1

`echo "$cmds" | grep "^$choice	" | cut -d '	' -f2-`


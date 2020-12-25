#! /bin/sh

# systemd based script


if [ -z `pgrep openvpn` ]; then
  notify-send "OpenVPN" "Starting VPN connection..."
  sudo systemctl start openvpn-client-airvpn
  transmission-daemon

else
  pkill "transmission-daemon"
  sudo systemctl stop openvpn-client-airvpn
  if [ -z `pgrep openvpn` ]; then
    notify-send "Openvpn" "Successfully terminated OpenVPN"
  else
    notify-send -u critical "Openvpn" "Failed to terminate OpenVPN"
  fi
fi


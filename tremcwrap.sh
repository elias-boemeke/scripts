#! /bin/sh

pidof "transmission-daemon" &> /dev/null || transmission-daemon
tremc

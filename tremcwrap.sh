#! /bin/sh

! pidof "transmission-daemon" &> /dev/null && transmission-daemon && sleep 1
tremc

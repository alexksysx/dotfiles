#!/bin/bash

delim=" | "

compton --backend glx --paint-on-overlay --vsync opengl-swc &

status() {
    echo $(date +'%H:%M %a %d.%m.%Y')
    echo $delim
    echo $(xkblayout-state print %n | cut -c-2)
    echo $delim
    echo "VOL $(volume-get)"
}

while :; do
    xsetroot -name "$(status | tr '\n' ' ')"
    sleep 1s
done

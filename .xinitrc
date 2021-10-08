#!/bin/sh

#echo "1) xfce4, 2) i3-wm"

#read choice

#if [ "$choice" = "1" ]; then
	#exec startxfce4 &
#elif [ "$choice" = "2" ]; then
	#exec i3 &
#fi

# exec startxfce4

#exec startxfce4

# -----dwm section start----#
#keyboard layout
#setxkbmap fr,ar, azerty -model pc10 -option grp:alt_shift_toggle
#setxkbmap fr, azerty -model pc10


#compositor
#picom --vsync -f &

#wallpaper
#nitrogen ./Pictures/wallhaven-rddgwm.jpg --set-zoom-fill

#keybinds

#execute dwm
#exec dwm

#-----dwm section end-----#




#bspwm

#keyboard layout
/home/salah/.scripts/mouse_keyboard.sh &

#cursor
xsetroot -cursor_name left_ptr

#compositor
#compton --vsync &
#xcompmgr &

xrdb -merge ~/.Xresources


#wallpaper
nitrogen --restore &
xset -dpms # Disables Energy Star features
xset s off # Disables screen saver
exec bspwm




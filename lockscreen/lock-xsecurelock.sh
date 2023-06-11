#!/bin/bash

# The MIT License.
#
# Copyright (c) 2021 Martín E. Zahnd < mzahnd at itba dot edu dot ar >
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#



# Folder with images/videos to display
if [[ "${HOSTNAME}" = 'wolf' || "${HOSTNAME}" = 'rhino' ]]; then
    readonly FOLDER='/home/public/Videos/LockScreen/Apple/'
elif [[ "${HOSTNAME}" = 'fox' ]]; then
    readonly FOLDER='/home/seabmo/Pictures/Wallpapers/Wolf/1920x1080/'
else
    readonly FOLDER=''
fi

readonly FIND_CMD="-type f -regex '^.*\.\(mov\|mp4\|mkv\|png\|jpg\|jpeg\)$'"

# For more environment variables run `xsecurelock --help`

# == Auth box ==
export XSECURELOCK_AUTH_CURSOR_BLINK=1
export XSECURELOCK_AUTH_TIMEOUT=5
export XSECURELOCK_AUTH_SOUNDS=0

# Single auth window = 1; One auth window per screen = 0
export XSECURELOCK_SINGLE_AUTH_WINDOW=0

export XSECURELOCK_SHOW_HOSTNAME=0
export XSECURELOCK_SHOW_USERNAME=1

# One of:
# asterisks / cursor / disco / emoji / emoticon / hidden / kaomoji /
# time / time_hex
export XSECURELOCK_PASSWORD_PROMPT='time_hex'

# -- Colors --
export XSECURELOCK_AUTH_BACKGROUND_COLOR='#003366'
export XSECURELOCK_AUTH_FOREGROUND_COLOR='#ffffff'
export XSECURELOCK_AUTH_WARNING_COLOR='#ff416d'

# -- Font --
export XSECURELOCK_FONT="IBM Plex Sans:style=Regular:size=14"

# -- Date-time --
export XSECURELOCK_DATETIME_FORMAT='%A %d, %B %Y - %H:%M:%S'
export XSECURELOCK_SHOW_DATETIME=1
# == END Auth box ==

# == General config ==

# Images
export XSECURELOCK_IMAGE_DURATION_SECONDS=15

# < 0 : Never blank the screen
# In seconds
export XSECURELOCK_BLANK_TIMEOUT=1800
export XSECURELOCK_COMPOSITE_OBSCURER=1
export XSECURELOCK_DISCARD_FIRST_KEYPRESS=1

export XSECURELOCK_LIST_VIDEOS_COMMAND="find ${FOLDER} ${FIND_CMD}"
export XSECURELOCK_SAVER=saver_mpv

# This can cause problems. Be careful.
export XSECURELOCK_FORCE_GRAB=1

# Milliseconds to wait after dimming (and before locking) when above xss-lock
# command line is used. Should be at least as large as the period time set
# using "xset s". Also used by wait_nonidle to know when to assume dimming and
# waiting has finished and exit.
export XSECURELOCK_WAIT_TIME_MS=0

# -- DIM --
#export XSECURELOCK_DIM_FPS=60
#export XSECURELOCK_DIM_OVERRIDE_COMPOSITOR_DETECTION=1
#export XSECURELOCK_DIM_TIME_MS=1500

# -- Keyboard --
# .. Brightness keys ..
export XSECURELOCK_KEY_XF86MonBrightnessDown_COMMAND='/usr/local/bin/backlight-manager dec 1'
export XSECURELOCK_KEY_XF86MonBrightnessUp_COMMAND='/usr/local/bin/backlight-manager inc 1'

# .. Media keys ..
export XSECURELOCK_KEY_XF86AudioMute_COMMAND="pactl set-sink-mute 0 toggle"
export XSECURELOCK_KEY_XF86AudioLowerVolume_COMMAND="pactl set-sink-volume 0 -1%"
export XSECURELOCK_KEY_XF86AudioRaiseVolume_COMMAND="pactl set-sink-volume 0 +1%"
export XSECURELOCK_KEY_XF86AudioPrev_COMMAND="playerctl previous"
export XSECURELOCK_KEY_XF86AudioNext_COMMAND="playerctl next"
export XSECURELOCK_KEY_XF86AudioPlay_COMMAND="playerctl play-pause"

# == END General config ==

xsecurelock &
exit ${?}

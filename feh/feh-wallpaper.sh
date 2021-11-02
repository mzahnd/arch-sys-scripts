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



# SYNOPSIS
#   script.sh [OPTIONS]
# OPTIONS
#       force   Run even if XDG_CURRENT_DESKTOP is not i3

# ====== EDITABLE SECTION ======

# Directory with a collection of wallpapers images to randomly set using feh.
# Images can be symbolic links.
readonly DIR="${HOME}/Pictures/Wallpapers/current/"

# How to scale images.
# Available options are:
#   scale
#   tile
#   center
#   max
#   fill
readonly SCALING='fill'

# ====== END EDITABLE SECTION ======

[ ${UID} -eq 0 ] && echo "Running as root is not allowed." && exit 1

# User must be running i3
[ "${1}" != "force" ] && \
    [ "${XDG_CURRENT_DESKTOP}" != "i3" ] && \
    exit 0

# Random wallpaper inside DIR
feh --quiet --bg-"${SCALING}" --randomize --recursive "${DIR}"

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


# ====== EDITABLE SECTION ======

readonly CURRENT_BRG_PATH='/sys/class/backlight/intel_backlight/brightness'
readonly MAX_BRG_PATH='/sys/class/backlight/intel_backlight/max_brightness'

readonly MAX_BRG="$(<"${MAX_BRG_PATH}")"

# ====== END EDITABLE SECTION ======

shopt -s extglob

# Run from inside script's directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if ! pushd "${SCRIPT_DIR}" &> /dev/null; then
    exit 1
fi

# Multiplier constant for brightness setting
CONST_MULTIPLIER_BRG=$(\
        echo "${MAX_BRG} / 100" | bc | awk '{print int($1+0.5)}' \
    )

readonly notification_tag="brightness-indicator-dunst-script"

# Help message
#
# Arguments
#   None
#
# Echoes
#   Usage message.
#
# Returns
#   0 : Success.
function usage()
{
    cat <<EOF
Usage: ${0##*/} [OPTION]

OPTIONS:
    i           N
    inc         N
    increment   N
                        Increment brightness by an integer N

    d           N
    dec         N
    decrement   N
                        Decrement brightness by an integer N

    s           N
    set-to      N
                        Set brightness to be exactly an integer N

    help
                        This message.
The MIT License
Copyright 2021 Martín E. Zahnd \< mzahnd at itba dot edu dot ar \>
    Run \`${0##*/} license\` to print license text.

Return values:
    0     : Success.
    1     : Failure.

EOF
    return 0
}

# License message.
#
# Arguments
#   None
#
# Echoes
#   Usage message.
#
# Returns
#   0 : Success.
function license()
{
    cat <<EOF
The MIT License.

Copyright (c) 2021 Martín E. Zahnd \< mzahnd at itba dot edu dot ar \>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
    return 0
}

function get_current_bright()
{
    cat "$CURRENT_BRG_PATH"
}

# Decrement brightness by a certain value
#
# Arguments
#   $1 : Integer between 0 and 100 representing the percentage of brightness
#       to decrement.
#
# Echoes
#   Nothing
#
# Returns
#   0 : Success
function decrement()
{
    local new_brg=0
    new_brg=$(\
            echo "$(get_current_bright) - ($CONST_MULTIPLIER_BRG*${1})" | \
            bc | \
        awk '{print int($1+0.5)}')

    if [ "${new_brg}" -le "0" ]; then
        new_brg=0
    fi

    echo "${new_brg}" > "${CURRENT_BRG_PATH}"

    return 0
}

# More brightness
#
# Arguments
#   $1 : Integer between 0 and 100 representing the percentage of brightness
#       to increment.
#
# Echoes
#   Nothing
#
# Returns
#   0 : Success.
function increment()
{
    local new_brg=0

    new_brg=$(\
            echo "($CONST_MULTIPLIER_BRG*${1}) + $(get_current_bright)" | \
            bc | awk '{print int($1+0.5)}' \
        )

    if [ "${new_brg}" -ge "${MAX_BRG}" ]; then
        new_brg=$(echo "${MAX_BRG}" | awk '{print int($1)}')
    fi

    echo "${new_brg}" > "${CURRENT_BRG_PATH}"

    return 0
}

# Set brightness to specific value
#
# Arguments
#   $1 : Integer between 0 and 100 representing the exact percentage of desired
#       brightness.
#
# Echoes
#   Nothing
#
# Returns
#   0 : Success.
function set_brg()
{
    local new_brg=0

    new_brg=$(\
            echo "$CONST_MULTIPLIER_BRG*${1}" | bc | awk '{print int($1+0.5)}' \
        )

    if [ "${new_brg}" -ge "${MAX_BRG}" ]; then
        new_brg=$(echo "${MAX_BRG}" | awk '{print int($1)}')
    fi

    if [ "${new_brg}" -le 0 ]; then
        new_brg=0
    fi

    echo "${new_brg}" > "${CURRENT_BRG_PATH}"

    return 0
}

function show_notification
{
    local brightness=0
    brightness="$(get_current_bright)"

    # Normalize
    brightness=$(echo "$brightness * 100 / $MAX_BRG" | bc)

    local icon=""
    local text="Brightness: ${brightness}%"
    local extra_hints="int:value:$brightness"

    if [[ "$brightness" -le 33 ]]; then
        icon="display-brightness-low-symbolic"
    elif [[ "$brightness" -le 66 ]]; then
        icon="display-brightness-medium-symbolic"
    else
        icon="display-brightness-high-symbolic"
    fi

    dunstify \
        --appname "${0##*/}" \
        --urgency low \
        --icon "$icon" \
        --hints "string:x-dunst-stack-tag:$notification_tag" \
        --hints "$extra_hints" \
        "$text"
}

# Go back to the directory from where the script has been called.
#
# Arguments
#   None
#
# Echoes
#   Nothing.
#
# Returns
#   0 : Always.
function popdir()
{
    # Exit script directory
    if popd &> /dev/null; then
        return 1
    fi

    return 0
}

trap popdir EXIT

# Argument $2 does not matter
case "${1,,}" in
    *(-)license) license; exit 0 ;;
esac

# Argument $2 must be a number in range [0; 100]
if [[ ! "${2}" =~ (^[[:digit:]]+$) ]]; then
usage
exit 1
elif [[ "${2}" -lt 0 || "${2}" -gt 100 ]]; then
usage
exit 1
fi

case "${1,,}" in
*(-)i|*(-)inc|*(-)increment) increment "${2}" ;;
*(-)d|*(-)dec|*(-)decrement) decrement "${2}" ;;
*(-)s|*(-)set-to) set_brg "${2}" ;;
*) usage; exit 1 ;;
esac

show_notification

exit 0

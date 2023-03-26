#!/usr/bin/env bash

# The MIT License.
#
# Copyright (c) 2023 Martín E. Zahnd < mzahnd at itba dot edu dot ar >
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

readonly SINK_NUMBER=0

# ====== END EDITABLE SECTION ======

shopt -s extglob

# Run from inside script's directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if ! pushd "${SCRIPT_DIR}" &> /dev/null; then
    exit 1
fi

# Arbitrary but unique message tag
readonly notification_tag="volume-indicator-dunst-script"

function usage
{
    cat <<EOF
Usage: ${0##*/} [OPTION]

OPTIONS:
    +N
                        Increment volume by an integer N

    -N
                        Decrement volume by an integer N

    =N
                        Set volume to be exactly an integer N

    m
                        Toggle mutle

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

function is_muted
{
    pactl get-sink-mute "$SINK_NUMBER" | awk -F ':' '{print $2}' | sed 's/[^a-z]//g'
}

function get_current_volume
{
    # Query pulseaudio for the current volume and whether or not the speaker is muted
    pactl get-sink-volume "$SINK_NUMBER" | head -1 | awk -F '/' '{print $2}' | sed 's/[^0-9]//g'
}

function change_volume
{
    pactl set-sink-volume "$SINK_NUMBER" "${1}%"
}

function toggle_mute
{
    pactl set-sink-mute "$SINK_NUMBER" toggle
}

function show_notification
{
    local volume=0
    volume="$(get_current_volume)"

    local icon=""
    local text="Volume: ${volume}%"
    local extra_hints="int:value:$volume"

    if [[ "$(is_muted)" == "yes" ]]; then
        echo "muted"
        icon="audio-volume-muted-blocking-symbolic"
        text="Volume muted"
        extra_hints=""
    elif [[ "$volume" -le 33 ]]; then
        icon="audio-volume-low-symbolic"
    elif [[ "$volume" -le 66 ]]; then
        icon="audio-volume-medium-symbolic"
    elif [[ "$volume" -le 100 ]]; then
        icon="audio-volume-high-symbolic"
    else
        icon="audio-volume-overamplified-symbolic"
    fi

    # shellcheck disable=SC2046
    dunstify \
        --appname "${0##*/}" \
        --urgency low \
        --icon "$icon" \
        --hints "string:x-dunst-stack-tag:$notification_tag" \
        $(if [[ -n "$extra_hints" ]]; then echo "--hints $extra_hints"; fi) \
        "$text"
}

case "${1,,}" in
    @(\+|-)+([0-9])) change_volume "${1,,}" ;;
@(=)+([0-9])) change_volume "${1##*'='}" ;;
@(m)) toggle_mute "${1##*'='}" ;;
*) usage; exit 1 ;;
esac

show_notification

exit 0

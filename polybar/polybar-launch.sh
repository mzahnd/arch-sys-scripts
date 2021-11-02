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
#       debug   Run in debug mode (does not deamonize)

# ====== EDITABLE SECTION ======

# Bars. At least one bar should be set here.
# Index are accessed are as `xrandr --listmonitors` says, so if the previous 
# command outputs something like this:
# 0: +*eDP1 ...
# 1: +HDMI1 ...
# The first bar (index 0) will be started in eDP1, and the second one in HDMI1.
readonly BARS=('bar_main' 'bar_secondary')

# Relative to user's home.
readonly CONFIG_FOLDER='.config/polybar/'

# ==== END EDITABLE SECTION ====


[ ${UID} -eq 0 ] && echo "Running as root is not possible." && exit 1

# User must be running i3
[ "${1}" != "force" ] && \
    [ "${XDG_CURRENT_DESKTOP}" != "i3" ] && \
    exit 0

[ "${1}" = "debug" ] && BAR_DEBUG=1

# Kill running Polybar instances of a given bar.
#
# Gives up after 30 seconds if there's at least one instance still running.
#
# Arguments
#   1 : Index in $BARS array of the bar whose instance one wants to kill.
#
# Echoes
#   Nothing.
#
# Returns
#   0 : Success.
#   1 : At least one polybar instance is still running after 30 seconds.
function kill_all_bars()
{
    local counter=0

    # Terminate already running bar instances
    killall --quiet 'polybar'
    
    # Wait until the processes have been shut down
    while pgrep -u $UID -x 'polybar' >/dev/null; do 
        counter=$((counter+1))
        sleep 1

        # Fail if bars couldn't be killed after 30 seconds
        [ "${counter}" -gt 30 ] && return 1
    done

    return 0
}

# Launch a Polybar instance for a given bar in a specific monitor.
#
# Unless $BAR_DEBUG is set to 1, bars are launched as a daemon.
#
# Arguments
#   1 : Bar index in $BARS.
#   2 : Monitor name as xrandr shows it. Run `xrandr --listmonitors`.
#
# Echoes
#   Nothing.
#
# Returns
#   0 : Always.
function launch_bar()
{
    if [ -n "${BAR_DEBUG}" ] && [ ${BAR_DEBUG} -eq 1 ]
    then
        MONITOR="${2}" polybar --log=info "${BARS["${1}"]}" &
    else
        # Daemonize
        (MONITOR="${2}" setsid polybar -q -r "${BARS["${1}"]}" &)
    fi
    return 0
}

# Get xrandr monitor number to use as index for $BARS.
#
# When there're more monitors than bars specified in $BARS, 0 is returned.
#
# Arguments
#   1 : Single line of the xrandr output after running `xrandr  --listmonitors`
#
# Echoes
#   Nothing.
#
# Returns
#  Number between 0 and the length of $BARS - 1 or 0 if there are more monitors
# than elements in the array.
function get_bar_index()
{
    local index=0

    index=$(echo "${1}" | awk '{print $1}' | cut -d ":" -f 1 -)
    [ -z ${BARS[${index}]} ] && index=0

    return $index
}

# Launch bars in all connected monitors.
#
# Runs `xrandr  --listmonitors` before calling those functions that need its
# output.
#
# Arguments
#   None.
#
# Echoes
#   Nothing.
#
# Returns
#   0 : Success.
#   1 : $CONFIG_FOLDER does not exist in $HOME.
function create_bars()
{
    local bar_index=0

    pushd "${HOME}/${CONFIG_FOLDER}" &> /dev/null || return 1

    while read -r line; do
        # Skip line "Monitors: N" in xrandr output.
        [[ "${line,,}" =~ (^[[:blank:]]*monitors.*$) ]] && continue

        get_bar_index "${line}"; bar_index=$?

        # Invalid/Undesired monitor
        [ ${bar_index} -eq 255 ] && continue

        launch_bar "${bar_index}" "$(echo "${line}" | awk '{print $NF}')"
   done < <(xrandr --listmonitors)

   popd &> /dev/null

   return 0
}

# Kill running bars and relaunch them in all connected monitors.
#
# Arguments
#   None.
#
# Echoes
#   Nothing.
#
# Returns
#   0 : Success.
#   1 : Error.
function main()
{
    kill_all_bars && create_bars && return 0
    return 1
}

main
exit $?


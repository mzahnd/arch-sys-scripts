#!/usr/bin/bash


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
#

# ====== EDITABLE SECTION ======

# Absolute path to configuration file(s). At least one is mandatory.
# "${HOME}/.config/conky/calendar.conf"
# "${HOME}/.config/conky/calendar-personal.conf"
readonly CONFIGS=(\
        "${HOME}/.config/conky/sys.conf"                \
    )

# ====== END EDITABLE SECTION ======

# Place this line before any function or command.
[ ${UID} -eq 0 ] && echo "Running as root is not allowed." && exit 1

# User must be running i3
[ "${1}" != "force" ] && \
    [ "${XDG_CURRENT_DESKTOP}" != "i3" ] && \
    exit 0

[ "${1}" = "debug" ] && CONKY_DEBUG=1

# Try to kill running conky instances.
#
# This function tries to kill all running conky processes and returns an error
# code if it fails to do so.
#
# Arguments
#   None
#
# Echoes
#   Nothing
#
# Returns
#   0 : Success.
#   1 : At least one Conky instance could not be killed.
function kill_conky()
{
    # local counter=0
    local pid_list=""
    # local children=""

    # Terminate already running conky instances
    #killall --quiet 'conky' # Old way

    # List 'conky' processes ignoring conky_launch (see the grep line). This is
    # very (!) important because 'kill' will try to _kill_ 'conky_launch' and
    # that's not what we want.
    # Then create a single-line space-separated string
    # pid_list=$(\
        #     ps x -o "%p %c" | \
        #         grep -iE '[[:alnum:]]+\ conky$' | \
        #         awk '{print $1}' ORS=' ' 2> /dev/null \
        # )

    # # List 'conky' direct children if they exist
    # [ -n "$pid_list" ] && children=$(\
        #     ps -o pid= --ppid $pid_list | awk '{print $1}' ORS=' ' 2> /dev/null \
        # )

    # if [ -n "$children" ]; then
    #    kill $children
    #    wait $children 2> /dev/null
    # fi
    # if [ -n "$pid_list" ]; then
    #    kill $pid_list
    #    wait $pid_list 2> /dev/null
    # fi

    pid_list=$(pgrep --euid "$USER" conky 2> /dev/null)
    wait $pid_list

    return 0
}

# Launch a Conky instance in a specific monitor using a configuration file.
#
# If $CONKY_DEBUG is set (is not 0), it will launch it using '--debug'
# argument. When unset, it daemonizes the process using '--daemonize'.
#
# Arguments
#   $1 : xinerama-head (from 0 to Monitors-1. With monitors as stated by
#        `xrandr --listactivemonitors`)
#   $2 : Configuration file. (Absolute path)
#
# Echoes
#   Nothing
#
# Returns
#   Conky exit code after launching.
function launch_conky()
{
    local args=(\
            --xinerama-head="${1}"  \
            --config="${2}"         \
        )

    [ "${CONKY_DEBUG}" ] && args+=('--debug') || args+=('--daemonize')

    conky --daemonize "${args[@]}"
    return $?
}

# Launch a Conky instance in each connected monitor.
#
# Arguments
#   None
#
# Echoes
#   Nothing
#
# Returns
#   Maximum Conky exit code after launching in each monitor.
function start_conky()
{
    local return_code=0
    local -r nmonitors="$(xrandr --listactivemonitors | \
                            awk 'NR==1 {print $2}')"

    for (( i=0; i<${nmonitors}; i++)); do
        for config_file in "${CONFIGS[@]}"; do
            launch_conky "${i}" "${config_file}"
            return_code=$(( ${return_code} > ${?} ? ${return_code} : ${?} ))
        done
    done

    return ${return_code}
}

# Main function.
#
# Tryies to kill old Conky instances and relaunches them in every connected
# monitor if succesfull.
#
# Arguments
#   None
#
# Echoes
#   Nothing
#
# Returns
#   Maximum Conky exit code after launching in each monitor.
function main()
{
    kill_conky && start_conky; return $?
}



main
exit $?

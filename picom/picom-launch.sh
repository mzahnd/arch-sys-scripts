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



# SYNOPSIS
#   script.sh [OPTIONS]
# OPTIONS
#       force   Run even if XDG_CURRENT_DESKTOP is not i3
#       debug   Run in debug mode (does not deamonize)

# ====== EDITABLE SECTION ======

# Enable (1) or disable (0) experimental backends
readonly EXPERIMENTAL_BACKENDS=1

# Optional. Provide full path.
readonly CONFIG_FILE_PATH="${HOME}/.config/picom/picom.conf"

# ====== END EDITABLE SECTION ======

[ ${UID} -eq 0 ] && echo "Running as root is not allowed." && exit 1

# User must be running i3
[ "${1}" != "force" ] && \
    [ "${XDG_CURRENT_DESKTOP}" != "i3" ] && \
    exit 0

[ "${1}" = "debug" ] && PICOM_DEBUG=1

# Kill running picom instances.
#
# Gives up after 30 seconds if there's at least one picom instance still 
# running.
#
# Arguments
#   None
#
# Echoes
#   Nothing.
#
# Returns
#   0 : Success.
#   1 : At least one picom instance is still running after 30 seconds.
function kill_picom()
{
    local counter=0

    # Terminate already running picom instances
    killall --quiet 'picom'

    # Wait until the processes have been shut down
    while pgrep -u $UID -x 'picom' >/dev/null; do
        counter=$((counter+1))
        sleep 1

        # Fail if picom couldn't be killed after 30 seconds
        [ "${counter}" -gt 30 ] && return 1
    done

    return 0
}

# Start a picom instance as a daemon (by default).
#
# When $PICOM_DEBUG is set to 1, the instance is not daemonized and picom is 
# started using '--log-level "DEBUG"' argument and the output is redirected to
# standard output (picom's default).
# 
# It is also posible that a specific configuration file has been provided in
# $CONFIG_FILE_PATH, and $EXPERIMENTAL_BACKENDS is set to 1. In any case, picom
# starts with the according command line arguments.
#
# Arguments
#   None
#
# Echoes
#   Nothing.
#
# Returns
#   Picom exit code.
function start_picom()
{
    local picom_return=0

    local args=()

    if [ -n "${PICOM_DEBUG}" ] && [ ${PICOM_DEBUG} -eq 1 ]
    then
        args+=("--log-level" "debug")
    else
        args+=("--daemon")
    fi

    [ "${EXPERIMENTAL_BACKENDS}" = "1" ] && args+=("--experimental-backends")


    [ -n "${CONFIG_FILE_PATH}" ] && args+=("--config" "${CONFIG_FILE_PATH}")

    picom "${args[@]}"
    picom_return=$?

    return ${picom_return}
}

# Kill already running picom instances and start a new one.
#
# Arguments
#   None.
#
# Echoes
#   Nothing.
#
# Returns
#   0   : Success killing old instances and starting a new one.
#   > 0 : Error.
function main()
{
    kill_picom && start_picom
    return $?
}

main
exit $?


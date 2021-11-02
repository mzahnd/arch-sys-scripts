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



# === Editable section ===

readonly TRANSFER_SCRIPT='lock-xsecurelock.sh'
# Time of inactivity before locking (in seconds)
readonly WAITING_TIME='900'
# Time to perform 'screen dimming' animation before locking (in seconds)
readonly DIMMING_TIME='30'

# === END Editable section ===

readonly SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
readonly SCRIPT_NAME="$(basename ${BASH_SOURCE[0]})"

TRANSFER_SCRIPT_PATH=''

# Installer's path
for file in "${SCRIPT_DIR}/${SCRIPT_NAME}.d"/*; do 
    [ "${file##*/}" = "${TRANSFER_SCRIPT}" ] \
    && TRANSFER_SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_NAME}.d/${TRANSFER_SCRIPT}"
done

# In case it's not installed
if [ -z "${TRANSFER_SCRIPT_PATH}" ]; then
    for file in "${SCRIPT_DIR}"/*; do 
        [ "${file##*/}" = "${TRANSFER_SCRIPT}" ] && \
            TRANSFER_SCRIPT_PATH="${SCRIPT_DIR}/${TRANSFER_SCRIPT}"
    done
fi

[ -z "${TRANSFER_SCRIPT_PATH}" ] && exit 1

killall -u ${USER} --quiet --wait xss-lock

# Activate xset
xset s on

# Lock screen WAITING_TIME seconds
xset s "${WAITING_TIME}" "${DIMMING_TIME}"

xss-lock    \
    --notifier='/usr/lib/xsecurelock/dimmer'    \
    --transfer-sleep-lock                       \
    -- "${TRANSFER_SCRIPT_PATH}"

exit ${?}

#!/bin/bash

# The MIT License.
#
# Copyright 2021 Martín E. Zahnd <mzahnd at itba dot edu dot ar>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
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
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# Script checked with ShellCheck (https://github.com/koalaman/shellcheck).



# Call 'install.sh' in all listed folders:
readonly SCRIPTS_TO_INSTALL=(\
        'backlight'     \
        'conky'         \
        'feh'           \
        'lockscreen'    \
        'microphone'    \
        'paccache'      \
        'paclist'       \
        'picom'         \
        'polybar'       \
        'volume'        \
    )

# Leave this before any function.
[ ${UID} -ne 0 ] && echo "Please run this script as root." && exit 1

# Print string with date-time.
#
# Arguments:
#   $* : String to print
#
# Returns:
#   0 : Always
function info()
{
    printf "[%s] %s\n" "$(date --rfc-3339='seconds')" "$*" >&2;
    return 0
}

# Print colored string with date-time.
#
# Arguments:
#   $1 : Color number (For red, you'll type \e[31m, then pass '31')
#   $* : String to print
#
# Returns:
#   0 : Always
function infoc()
{
    local clr="${1}"
    shift
    printf "[%s] \e[${clr}m%s\e[0m\n" "$(date --rfc-3339='seconds')" "$*" >&2;
    return 0
}

function install_script()
{
    local retval=0

    pushd "${1}" &> /dev/null || (info "Unable to access ${1}" && return 1)
    if [ -f 'install.sh' ]; then
        info "Installing ${1}"
        /bin/bash 'install.sh'; retval=$?
        info "Installation finished with exit code $retval"
    else
        info "File 'install.sh' not found."
        retval=1
    fi
    popd &> /dev/null

    return $retval
}

SCRIPT_EXIT_CODE=0
for script in "${SCRIPTS_TO_INSTALL[@]}"; do
    install_script "${script}"
    SCRIPT_EXIT_CODE=$(( SCRIPT_EXIT_CODE | $? ))
done

exit $SCRIPT_EXIT_CODE

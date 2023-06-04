#!/usr/bin/env bash

# The MIT License.
#
# Copyright (c) 2023 Martín E. Zahnd < zahndme at gmail dot com >
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

readonly PUBLIC_HOME="/home/public/"

# ====== END EDITABLE SECTION ======

shopt -s extglob

# Run from inside script's directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
pushd "$SCRIPT_DIR" &> /dev/null || exit 1

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
Usage ${0##*/} [OPTION]

Available OPTIONs:
    --license
    license
                        License message.

    --help
     -h
    help
                        This message.

The MIT License
Copyright 2023 Martín E. Zahnd \< zahndme at gmail dot com \>
    Run \`${0##*/} license\` to print license text.
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

Copyright (c) 2023 Martín E. Zahnd \< zahndme at gmail dot com \>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
    return 0
}

# Print information message to standard output.
#
# Printed message has a timestamp using standard RFC 3339 (up to seconds of
# precision).
#
# Arguments
#   * : Message to print.
#
# Echoes
#   Message with format
#   [date-time] message
#
# Returns
#   0 : Always.
function info()
{
    printf "[%s] %s\n" "$(date --rfc-3339='seconds')" "$*" >&2;
    return 0
}

# Set folders to root:users with 775
#
# Arguments
#   1 : Directory to store the three packages lists.
#
# Echoes
#   Error message when needed.
#
# Returns
#   0 : Always.
function set_folders_permission()
{
    find "$PUBLIC_HOME" -type d \
        -exec chown root:users "{}" ';' \
        -exec chmod 775 "{}" ';'

    return 0
}

# Set files to root:users with read (all) and write permission (except other)
#
# Arguments
#   1 : Directory to store the three packages lists.
#
# Echoes
#   Error message when needed.
#
# Returns
#   0 : Always.
function set_files_permission()
{
    find "$PUBLIC_HOME" -type f \
        -exec chown root:users "{}" ';' \
        -exec chmod a+r,u+w,g+w "{}" ';'

    return 0
}

# === MAIN ===
_SCRIPT_EXIT_CODE=0

case "${1,,}" in
    *(-)help|*(-)h)
    usage
    _SCRIPT_EXIT_CODE=1
    ;;
*(-)license)
license
_SCRIPT_EXIT_CODE=1
;;
*)

if [ $UID -ne 0 ]; then
    info "Error: Must be run as superuser."
    _SCRIPT_EXIT_CODE=1
else
    set_folders_permission
    set_files_permission
    _SCRIPT_EXIT_CODE=0
fi
;;
esac

# Exit script directory
popd &> /dev/null

exit $_SCRIPT_EXIT_CODE

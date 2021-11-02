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

FILE_OFFICIAL_PKGS="packages_list_oficial"
FILE_OPT_DEPS="packages_list_optional_deps"
FILE_AUR_PKGS="packages_list_aur"

# ====== END EDITABLE SECTION ======

shopt -s extglob

# Run from inside script's directory
SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
pushd "${SCRIPT_DIR}" &> /dev/null

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
    --install [folder]
    install   [folder]
                        Install packages listed in files:
                            - Official packages:     '${FILE_OFFICIAL_PKGS}'
                            - Optional dependencies: '${FILE_OPT_DEPS}'
                            - AUR packages:          '${FILE_AUR_PKGS}'
                        Optional argument 'folder' tells where these files are.
                        If 'folder' is not specified, the files will be picked
                        from the directory with the script.
                        If any of these files is not found, it'll be skipped.

    --backup  [folder]
    bckp      [folder]
                        List installed packages in these files inside 'folder':
                            - Official packages:     '${FILE_OFFICIAL_PKGS}'
                            - Optional dependencies: '${FILE_OPT_DEPS}'
                            - AUR packages:          '${FILE_AUR_PKGS}'
                        If optional argument 'folder' is not specified, the 
                        files listed above will be stored in the directory 
                        containing the script.

    --help
     -h
    help
                        This message.

The MIT License
Copyright 2021 Martín E. Zahnd \< mzahnd at itba dot edu dot ar \>
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

Copyright (c) 2021 Martín E. Zahnd \< mzahnd at itba dot edu dot ar \>

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

# Backup a file y replace it with another one.
#
# File given as second argument gets a '.bckp' file extension appended and the
# file that represents the first argument replaces the original.
#
# Arguments
#   1 : New file.
#   2 : File to be backed up and replaced.
#
# Echoes
#   Error message if needed.
#
# Returns
#   0 : Success.
#   1 : Failure due to developer error (most probably: argument $1 is not a 
#   regular file)
function replace_files () 
{
    [ -f "${2}" ] && mv "${2}" "${2}.bckp"
    [ -f "${1}" ] && mv "${1}" "${2}" || (info "Developer error!" && return 1)

    # Make readable for everyone
    chmod 444 "${2}"
    return 0
}

# Install packages from a list of files.
#
# A full package list update is performed at the beggining, and then packages
# installation is performed using the provided lists. It uses Yay for AUR 
# packages.
#
# Files are specified using $FILE_OFFICIAL_PKGS, $FILE_OPT_DEPS, and 
# $FILE_AUR_PKGS variables.
#
# Arguments
#   1 : [Optional] Parent folder with all three list files.
#
# Echoes
#   Error message if needed.
#
# Returns
#       0 : Success.
#   1 - 3 : Ammount of list files that could not be found or failed during 
#          installation.
function install_packages()
{
    local return_code=0

    [ "${1}" ] \
        && FILE_OFFICIAL_PKGS="${1}/${FILE_OFFICIAL_PKGS}"  \
        && FILE_OPT_DEPS="${1}/${FILE_OPT_DEPS}"            \
        && FILE_AUR_PKGS="${1}/${FILE_AUR_PKGS}"

    # Refresh package database
    sudo pacman -Syy

    [ -f "${FILE_OFFICIAL_PKGS}" ] &&                               \
        ( sudo pacman -S --needed - < ${FILE_OFFICIAL_PKGS};        \
        return_code=$(($? + $return_code)) )                        \
    || info "File ${FILE_OFFICIAL_PKGS} does not exist. Skipping."; \
        return_code=$(($return_code + 1))

    [ -f "${FILE_OPT_DEPS}" ] &&                                    \
        ( sudo pacman -S --asdeps --needed - < ${FILE_OPT_DEPS};    \
        return_code=$(($? + $return_code)) )                        \
    || info "File ${FILE_OPT_DEPS} does not exist. Skipping.";      \
        return_code=$(($return_code + 1))

    [ -f "${FILE_AUR_PKGS}" ] &&                                    \
        ( yay -S --aur --needed - < ${FILE_AUR_PKGS}                \
        return_code=$(($? + $return_code)) )                        \
    || info "File ${FILE_AUR_PKGS} does not exist. Skipping.";      \
        return_code=$(($return_code + 1))

    return $return_code
}

# Export a list of installed packages in the running machine.
#
# Lists are exported to $FILE_OFFICIAL_PKGS, $FILE_OPT_DEPS, and 
# $FILE_AUR_PKGS except when argument 1 is given.
#
# Arguments
#   1 : Directory to store the three packages lists.
#
# Echoes
#   Error message when needed.
#
# Returns
#   0 : Success.
#   1 : Error.
function backup_packages()
{
    local return_code=0

    local mktemp_template='packages_list.tmp.XXXXXX'
    local official_pkgs_tmp=$(mktemp -p '/tmp' "${mktemp_template}")
    local opt_deps_tmp=$(mktemp -p '/tmp' "${mktemp_template}")
    local aur_pkgs_tmp=$(mktemp -p '/tmp' "${mktemp_template}")

    if [ "${1}" ]; then
       [ ! -d "${1}" ] && mkdir -p "${1}" &> /dev/null
        if [ -w "${1}" ]; then
            FILE_OFFICIAL_PKGS="${1}/${FILE_OFFICIAL_PKGS}"
            FILE_OPT_DEPS="${1}/${FILE_OPT_DEPS}"
            FILE_AUR_PKGS="${1}/${FILE_AUR_PKGS}"
        elif [ -w "." ]; then
            info "No write permission for directory ${1}. Storing in ${PWD}"

            return_code=1
        else
            local tmpdir=$(mktemp -p '/tmp' -d "${mktemp_template}")
            info "No write permission for directory ${2}. Storing in ${tmpdir}"
            FILE_OFFICIAL_PKGS="${tmpdir}/${FILE_OFFICIAL_PKGS}"
            FILE_OPT_DEPS="${tmpdir}/${FILE_OPT_DEPS}"
            FILE_AUR_PKGS="${tmpdir}/${FILE_AUR_PKGS}"

            return_code=1
        fi
    fi

    pacman -Qqen > "${official_pkgs_tmp}" \
        && replace_files "${official_pkgs_tmp}" "${FILE_OFFICIAL_PKGS}" \
        || return_code=1

    comm -13 \
        <(pacman -Qqdt | sort)  \
        <(pacman -Qqdtt | sort) \
        > ${opt_deps_tmp}       \
    && replace_files "${opt_deps_tmp}" "${FILE_OPT_DEPS}" \
    || return_code=1

    pacman -Qqem > ${aur_pkgs_tmp} \
    && replace_files "${aur_pkgs_tmp}" "${FILE_AUR_PKGS}" \
    || return_code=1

    return ${return_code}
}

# === MAIN ===
_SCRIPT_EXIT_CODE=0

[ $UID -eq 0 ] && info "Warning: Running as superuser."

case "${1,,}" in
    *(-)install)
        install_packages "${2}";    _SCRIPT_EXIT_CODE=$?
        ;;
    *(-)backup|*(-)bckp)
        backup_packages "${2}";     _SCRIPT_EXIT_CODE=$?
        ;;
    *(-)license)
        license;                    _SCRIPT_EXIT_CODE=1
        ;;
    *)
        usage;                      _SCRIPT_EXIT_CODE=1
        ;;
esac

# Exit script directory
popd &> /dev/null

exit ${_SCRIPT_EXIT_CODE}

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


# Script checked with ShellCheck (https://github.com/koalaman/shellcheck).



# Automated script and systemd services and timers installation.

# === Modifiable section ===
# --- SCRIPT ---
# Name of executable file. This is the name you'll be typing in your shell.
readonly SCRIPT_NAME='paccache-clean'
# Single file. Will be renamed as SCRIPT_NAME
readonly SCRIPT_FILE='paccache-clean.sh'
# Will be placed under '/usr/local/bin/${SCRIPT_NAME}.d/
readonly SCRIPT_EXTRAS=()

# --- SYSTEMD SERVICES ---
# Timers and services with the same filename but .service and .timer extension.
# DO NOT add the file extension here. Both '.service' and '.timer' are assumed.
readonly SERVICES_WTIMER=(  \
    'pacman-clean-cache'
)

# This are standalone services that are always running.
# DO NOT add the file extension here. '.services' is assumed.
readonly SERVICES_NTIMER=()

# === END of Modifiable section ===

readonly _INSTALL_PATH='/usr/local/bin/'
readonly _SYSTEMD_SERVICES_PATH='/etc/systemd/system/'

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

# Verify that all files listed in the user variables are actually readable.
#
# Arguments:
#   None
#
# Return codes:
# 0 : Everything is OK
# 1 : No systemd. Install without services.
# 2 : Listed file not found. Abort.
function verify_files_dirs()
{
    local return_code=0
    
    # systemd
    if [ ${#SERVICES_WTIMER[@]} -gt 0 ] || [ ${#SERVICES_NTIMER[@]} -gt 0 ]
    then
        # Keep pre-set IFS
        local tmp_ifs="${IFS}"
        IFS=" " read -r -a sysd_path  <<< "$(whereis systemd)"
        IFS="${tmp_ifs}"
        
        ( [ ${#sysd_path[@]} -le 1 ] && info "systemd not found." ) \
        || ( [ ! -d "${_SYSTEMD_SERVICES_PATH}" ] \
            && info "systemd services directory not found." ) \
        && info "Services will not be installed" && return_code=1
    fi

    # Script main file
    [ ! -r "${SCRIPT_FILE}" ] \
        && info "Unable to read file '${SCRIPT_FILE}'. Aborting" \
        && return_code=2

    # Extra script files
    for file in "${SCRIPT_EXTRAS[@]}"; do
        [ ! -r "${file}" ] \
            && info "Unable to read file '${file}'. Aborting" \
            && return_code=2
    done

    # Service files with timers
    for file in "${SERVICES_WTIMER[@]}"; do
        [ ! -r "${file}.timer" ] \
            && info "Unable to read file '${file}.timer'. Aborting" \
            && return_code=2

        [ ! -r "${file}.service" ] \
            && info "Unable to read file '${file}.service'. Aborting" \
            && return_code=2
    done

    # Standalone service files
    for file in "${SERVICES_NTIMER[@]}"; do
        [ ! -r "${file}.service" ] \
            && info "Unable to read file '${file}.service'. Aborting" \
            && return_code=2
    done

    return $return_code
}

# Copy file to certain respecting origin subfolders.
#
# When called with arguments 
#   copy_file 'myfile.sh' '/usr/local/bin/script.d'
# 'myfile.sh' will be copied to '/usr/local/bin/script.d/myfile.sh'
#
# When called with arguments 
#   copy_file 'mydir/myfile.sh' '/usr/local/bin/script.d'
# 'myfile.sh' will be copied to '/usr/local/bin/script.d/mydir/myfile.sh'
#
# Arguments:
#   $1 : Origin
#   $2 : Destination 
#
# Returns:
#   0 : Always
function copy_file()
{
    local origin="${1}"
    local dest="${2}"

    if [[ "${origin}" =~ '/' ]]; then
        mkdir -p "${dest}/${origin%/*}" &> /dev/null
        dest="${dest}/${origin%/*}/"
    fi
    cp "${origin##*/}" "${dest}"

    return 0
}

# Copy script files as listed in SCRIPT_FILE and SCRIPT_EXTRAS.
#
# After copying files it grants read permissions for everyone and execute 
# permission only for SCRIPT_FILE. (owner -root- has r+w+x).
#
# NOTE: SCRIPT_FILE is copied as SCRIPT_NAME.
#
# Arguments:
#   None
#
# Returns:
#   0 : Always
function copy_script()
{
    info "Copying main script file."
    copy_file "${SCRIPT_FILE}" "${_INSTALL_PATH}/${SCRIPT_NAME}"

    if [ ${#SCRIPT_EXTRAS[@]} -gt 0 ]; then
        info "Copying extra script files in " \
            "'${_INSTALL_PATH}/${SCRIPT_NAME}.d'"
        mkdir -p "${_INSTALL_PATH}/${SCRIPT_NAME}.d" &> /dev/null
        for file in "${SCRIPT_EXTRAS[@]}"; do
            copy_file "${file}" "${_INSTALL_PATH}/${SCRIPT_NAME}.d/"
        done

        # Files inside are r+w for root and r for everyone else
        chmod -R 644 "${_INSTALL_PATH}/${SCRIPT_NAME}.d/"
        # Folder containing them is r+w+x for root, r+x for everyone else (so 
        # ls, tree, etc works)
        chmod 755 "${_INSTALL_PATH}/${SCRIPT_NAME}.d/"
    fi

    chmod 755 "${_INSTALL_PATH}/${SCRIPT_NAME}"

    return 0
}

# Copy service and timer files to _SYSTEMD_SERVICES_PATH.
#
# Each file is granted read permission for everyone except root (owner), who 
# has r+w.
#
# Arguments:
#   None
#
# Returns:
#   0 : Always
function copy_services()
{
    [ "${#SERVICES_WTIMER[@]}" -gt 0 ] && info "Copying timers and services."
    for file in "${SERVICES_WTIMER[@]}"; do
        copy_file "${file}.timer" "${_SYSTEMD_SERVICES_PATH}/"
        copy_file "${file}.service" "${_SYSTEMD_SERVICES_PATH}/"

        chmod 644 "${_SYSTEMD_SERVICES_PATH}/${file}"{.timer,.service} 
    done

    [ "${#SERVICES_NTIMER[@]}" -gt 0 ] && info "Copying standalone services."
    for file in "${SERVICES_NTIMER[@]}"; do
        copy_file "${file}.service" "${_SYSTEMD_SERVICES_PATH}/"

        chmod 644 "${_SYSTEMD_SERVICES_PATH}/${file}"
    done

    return 0
}

# Enable systemd timers and standalone services.
#
# Arguments:
#   None
#
# Returns:
#   0 : Always
function enable_services()
{
    [ "${#SERVICES_WTIMER[@]}" -gt 0 ] && info "Enabling timers."
    for service in "${SERVICES_WTIMER[@]}"; do
        systemctl enable "${service}.timer"
    done

    [ "${#SERVICES_NTIMER[@]}" -gt 0 ] && info "Enabling standalone services."
    for service in "${SERVICES_NTIMER[@]}"; do
        systemctl enable "${service}.service"
    done
    return 0
}

# Start systemd timers and standalone services.
#
# Arguments:
#   None
#
# Returns:
#   0 : Always
function start_services()
{
    [ "${#SERVICES_WTIMER[@]}" -gt 0 ] && info "Starting timers."
    for service in "${SERVICES_WTIMER[@]}"; do
        systemctl start "${service}.timer"
    done

    [ "${#SERVICES_NTIMER[@]}" -gt 0 ] && info "Starting standalone services."
    for service in "${SERVICES_NTIMER[@]}"; do
        systemctl start  "${service}.service"
    done

    return 0
}

# Copy services and timer files and start/enable them, as desired by user.
#
# Arguments:
#   None
#
# Returns:
#   0 : Always
function install_services()
{
    copy_services

    systemctl daemon-reload

    PS3="Would you like to enable and start services and timers? "
    select opt in   "Enable and start them"         \
                    "Enable without starting them"  \
                    "Start without enabling them"   \
                    "Do nothing"
    do
        case "${opt}" in
            "Enable and start them")
                enable_services
                start_services 
                break
                ;;
            "Enable without starting them")
                enable_services
                break
                ;;
            "Start without enabling them")
                start_services 
                break
                ;;
            "Do nothing")
                info "Omitting."
                break
                ;;
        esac
    done

    return 0
}

function main()
{
    local return_code=0

    verify_files_dirs
    case $? in
        0)
            copy_script
            if [ ${#SERVICES_WTIMER[@]} -gt 0 ] \
                || [ ${#SERVICES_NTIMER[@]} -gt 0 ]
            then
                install_services
            fi
            return_code=0
            ;;
        1)
            copy_script
            return_code=1
            ;;
        2)
            return_code=2
            ;;
        *)
            info "Unknown error."
            return_code=2
            ;;
    esac
    return $return_code
}

main; exit $?


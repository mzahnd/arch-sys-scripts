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



# ==== EDITABLE SECTION ====

# List of ignored users when trying to clean YAY cache.
# You can list all users in the system running
# `awk -F: '{ print $1 }' /etc/passwd`
readonly SKIPPED_USERS=('nobody' 'nobody4')

# Number of the latest version of installed packages that should be kept.
# Applies to both pacman and yay cache.
readonly KEEP_UPDATED=2
# Number of the latest version of removed packages that should be kept.
# Applies to both pacman and yay cache.
readonly KEEP_UNINSTALLED=0

# ==== END EDITABLE SECTION ====

# Place this line before any function or command.
# [ ${UID} -ne 0 ] && echo "Please run this script as root." && exit 1


# Keep the latest version of installed packages in a specific user's yay cache.
#
# Given a user UID and its absolute home path, it will try to find .cache/yay/
# directory and remove all but the latest $KEEP_UPDATED versions of all 
# packages and the latest $KEEP_UNINSTALLED version of removed packages.
#
# Arguments
#   $1 : User's UID
#   $2 : User's absolute home path
#
# Echoes
#   Nothing
#
# Returns
#   0 : Success.
function yay_cache()
{
    local -r cache_root="${2}/.cache/yay/"

    [ ! -d "${cache_root}" ] && return 0
    # paccache does not recurse into subdirectories.
    # In order to get them listed, find gets all subdirectories in $cache_dir
    # and prints them with '--cachedir' before the path name (%p) in order to
    # pass this string directely to paccache.
    # Note that '! -path ${cache_dir}' makes find utility not printing the
    # starting point to stdout (the same could be achieved piping tail -n +2).
    #
    # WARNING: If you're going to edit the printf flag, keep the spaces around
    #         to avoid printing something like 
    #         '--cachedir /home/john/.cache/yay/yay--cachedir /home/ ... '
    local -r cached_pkgs="$(find ${cache_root}   \
        -maxdepth 1 ! -path ${cache_root}        \
        -type d                                 \
        -printf ' --cachedir %p ')"

    # Quoting ${cached_pkgs} here will result in paccache interpreting
    # the string in an undesired way.
    /usr/bin/paccache --verbose ${cached_pkgs} \
        --keep "${KEEP_UPDATED}" --remove
    /usr/bin/paccache --verbose ${cached_pkgs} \
        --keep "${KEEP_UNINSTALLED}" --uninstalled --remove

    return 0
}


set -x
# Yay
#while read -r user; do
#    username="${user%%:*}"
#    # Remove username
#    user="${user/${username}}"
#    user="${user:1}"
#
#    # User should have UID >= 1000 and NOT be in SKIPPED_USERS array.
#    # 'user%%:*' expands to get the UID
#    # 'user##*:' expands to get the home path
#    [ "${user%%:*}" -ge "1000" ] && \
#        [[ ! "${SKIPPED_USERS[@]}" =~ "${username}" ]] && \
#done < <(awk -v FS=':' '{printf "%s:%s:%s\n",$1,$3,$6;}' /etc/passwd)
yay_cache "seabmo" "/home/seabmo"
set +x

exit 0

#!/usr/bin/env bash

# The MIT License.
#
# Copyright (c) 2026 Martín E. Zahnd < martin at zahnd dot me >
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

# Empty

# ====== END EDITABLE SECTION ======

# Run from inside script's directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if ! pushd "${SCRIPT_DIR}" &>/dev/null; then
    exit 1
fi

function usage {
    cat <<EOF
Usage: ${0##*/} [OPTION]

        echo "Usage: $0 [--current | performance | powersave]"

OPTIONS:
    --current           Current CPU scaling governor (performance or powersave)

    performance         Set scaling governor to performance in all CPUs.

    powersave           Set scaling governor to powersave in all CPUs.

    --help              This message.
The MIT License
Copyright 2026 Martín E. Zahnd \< martin at zahnd dot me \>
    Run \`${0##*/} license\` to print license text.

Return values:
    0     : Success.
    1     : Failure.

EOF
    return 0
}

function get_scaling_governor() {
    echo "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    return 0
}

function set_scaling_governor() {
    local new_governor="$1"
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "${new_governor}" >"$cpu"
    done
    return 0
}

case "$1" in
    --icon)
        case "$(get_scaling_governor)" in
            performance) echo "󱪈" ;;
            powersave) echo "󰌪" ;;
            *) echo "?" ;;
        esac
        ;;
    performance)
        set_scaling_governor "performance"
        ;;
    powersave)
        set_scaling_governor "powersave"
        ;;
    --help)
        usage
        exit 1
        ;;
    *)
        echo "$(get_scaling_governor)"
        ;;
esac

exit 0

#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if ! pushd "${SCRIPT_DIR}" &> /dev/null; then
    exit 1
fi

SERVER_IP="192.168.1.140"
SERVER_PORT=8095
MIRRORLIST="/etc/pacman.d/mirrorlist"

cp "$MIRRORLIST" mirrorlist
python3 paclan_server.py --host "$SERVER_IP" --port "$SERVER_PORT"

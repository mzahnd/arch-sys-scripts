#!/usr/bin/bash

SERVER_IP="192.168.8.140"
SERVER_PORT=8095
MIRRORLIST="/etc/pacman.d/mirrorlist"

cp "$MIRRORLIST" mirrorlist
python3 paclan_server.py --host "$SERVER_IP" --port "$SERVER_PORT"

#!/usr/bin/bash

SERVER_IP="192.168.1.140"
SERVER_PORT=8095

MIRRORLIST="/etc/pacman.d/mirrorlist"

if ! curl -O "$SERVER_IP:$SERVER_PORT/mirrorlist"
then
    echo "Could not download mirrorlist"
    exit 1
fi

sed -i "1s@^@Server = http://$SERVER_IP:$SERVER_PORT\n@" mirrorlist

echo "Copying mirrorlist file to '$MIRRORLIST'"
sudo cp mirrorlist "$MIRRORLIST"

if alias updatesys >/dev/null 2>&1; then
    updatesys
else
    sudo pacman -Syy && \
        sudo pacman -S -q --needed archlinux-keyring && \
        sudo pacman -Su && \
        yay --aur --batchinstall -Su
fi

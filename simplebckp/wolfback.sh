#!/usr/bin/bash

# shellcheck disable=2155
readonly SCRIPTNAME=$(basename "$0")

function myecho()
{
    echo "[$SCRIPTNAME] $*"
}

if [[ $UID -eq 0 ]]; then
    myecho "Do not call as root."
    exit 1
fi

readonly CALLING_USER="$USER"

readonly OUTPUT_DIR="/home/seabmo/backups/"
readonly FILENAME="wolf.tar.zst"

BACKMEUP=("/etc" \
        "$HOME/.config" \
        "$HOME/.cups" \
        "$HOME/.dotfiles" \
        "$HOME/.local/share/applications" \
        "$HOME/.local/share/fonts" \
        "$HOME/.local/share/icons" \
        "$HOME/.scripts" \
        "$HOME/.themes" \
    )

EXCLUDEME=(".Trash-[0-9]*"\
        "*.log$" \
        "/etc/old_etc" \
        "$HOME/.config/borg" \
        "$HOME/.config/chromium" \
        "$HOME/.config/google-chrome" \
        "$HOME/.config/code-oss" \
        "$HOME/.config/Code\ -\ OSS" \
        "$HOME/.config/discord" \
        "$HOME/.config/Electron" \
        "$HOME/.config/google-chrome" \
        "$HOME/.config/@joplin" \
        "$HOME/.config/Joplin" \
        "$HOME/.config/joplin-desktop" \
        "$HOME/.config/Mailspring" \
        "$HOME/.config/obsidian" \
        "$HOME/.config/opera" \
        "$HOME/.config/Slack" \
        "$HOME/.config/syncthing/*.db" \
        "$HOME/.config/spotify" \
    )

TAR_EXCLUDE=()
for exc in "${EXCLUDEME[@]}"; do
    TAR_EXCLUDE+=("--exclude=$exc")
done

for back in "${BACKMEUP[@]}"; do
    myecho "tar & zstd dir: $back"
done

sudo tar --create \
    --file="$OUTPUT_DIR/$FILENAME" \
    --directory=/ \
    "${TAR_EXCLUDE[@]}" \
    --exclude-backups \
    --exclude-caches-all \
    --use-compress-program="zstd -8 --threads=$(nproc --ignore=1) --rsyncable" \
    "${BACKMEUP[@]}"

myecho "Restoring permissions"
sudo chown "$CALLING_USER:$CALLING_USER" "$OUTPUT_DIR/$FILENAME"

myecho "Done"

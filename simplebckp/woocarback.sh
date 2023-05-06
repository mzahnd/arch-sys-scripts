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

readonly OUTPUT_DIR="/home/seabmo/backups/woocar/"
readonly FILENAME="woocar.tar.zst"

readonly RCLONE_REMOTE_FOLDER="woocar:"

# Do NOT end with /
BACKMEUP=("/home/seabmo/eds/dev/woocar")

EXCLUDEME=(".Trash-[0-9]*"\
        "*.log$" \
    )

TAR_EXCLUDE=()
for exc in "${EXCLUDEME[@]}"; do
    TAR_EXCLUDE+=("--exclude=$exc")
done

for back in "${BACKMEUP[@]}"; do
    myecho "tar & zstd dir: $back"

    tar --create \
        --file="$OUTPUT_DIR/$FILENAME" \
        --directory="${back%/*}/" \
        "${TAR_EXCLUDE[@]}" \
        --exclude-backups \
        --exclude-caches-all \
        --use-compress-program="zstd -8 --threads=$(nproc --ignore=1) --rsyncable" \
        "${back##*/}"

done

myecho "Done"

myecho "Uploading..."

#   --dry-run \
    rclone sync "$OUTPUT_DIR" "$RCLONE_REMOTE_FOLDER" \
    --error-on-no-transfer \
    --verbose \
    --update
rclone_return=$?


if [ $rclone_return -eq 9 ]; then
    myecho "Operation successful. No files transferred."
elif [ $rclone_return -eq 0 ]; then
    myecho "Operation successful."
else
    myecho "Error!"
fi

#!/usr/bin/env bash

function myecho()
{
    echo -en "\e[34m[$(date --rfc-3339='seconds')]\e[0m "
    echo "$*"
}

if [[ $UID -eq 0 ]]; then
    myecho "Do not run as root."
    exit 1
fi

readonly OUTPUT_DIR="${HOME}/backups/woocar/"
readonly FILENAME="woocar"
readonly EXTENSION=".tar.zst"

readonly RCLONE_REMOTE_FOLDER="woocar:"

# Do NOT end with /
BACKMEUP=("${HOME}/eds/dev/woocar")

EXCLUDEME=(\
        "*.log$" \
        "*ffs_db*" \
        "*ffs_sync*"* \
    )

EXCLUDEME_FOLDERS=(\
        "*/.ipynb_checkpoints" \
        "*/.ruff_cache" \
        "*/.Rproj.user" \
        "*/.stfolder" \
        "*/.stversions" \
        "*/.Trash-[0-9]*/*" \
    )


TAR_EXCLUDE=()
for exc in "${EXCLUDEME[@]}"; do
    TAR_EXCLUDE+=("--exclude=$exc")
done

FIND_EXCLUDE=()
for exc in "${EXCLUDEME_FOLDERS[@]}"; do
    FIND_EXCLUDE+=(" " "-not" "-path" "$exc")
done

tar_files ()
{
    local tar_file_suffix="$1"
    shift

    tar --create \
        --file="$OUTPUT_DIR/${FILENAME}_${tar_file_suffix}${EXTENSION}" \
        "${TAR_EXCLUDE[@]}" \
        --exclude-backups \
        --exclude-caches-all \
        --use-compress-program="zstd -8 --threads=$(nproc --ignore=1) --rsyncable" \
        "${@}"
}

for back in "${BACKMEUP[@]}"; do
    # Go to parent directory
    pushd "${back%/*}" || exit 1

    myecho "tar & zstd files in: $back"

    back="${back##*/}"

    readarray -d '' files_list < <(\
        find "$back" \
            -maxdepth 1 -mindepth 0 -type f -print0 \
    )

    readarray -d '' folders_list < <(\
        # shellcheck disable=2068
        find "$back" \
            -maxdepth 1 -mindepth 1 -type d ${FIND_EXCLUDE[@]} -print0 \
    )

    myecho "Tar files"
    tar_files "files" "${files_list[@]}"
    
    for folder in "${folders_list[@]}"; do
        myecho "Tar folder: $folder"
        tar_files "${folder##*/}" "$folder"
    done

    files_list=()
    folders_list=()

    popd || exit 1
done

myecho "Done"

myecho "Uploading..."

#    --dry-run \
    rclone sync "$OUTPUT_DIR" "$RCLONE_REMOTE_FOLDER" \
    --checksum \
    --error-on-no-transfer \
    --delete-after \
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

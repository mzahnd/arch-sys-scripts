#!/usr/bin/env bash

readonly OUTPUT="${HOME}/Documents/Telefonino/"
readonly PHONE="/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_R58W50AJK2M/" # Galaxy A24 Martin

# Relative to $PHONE
phone_dirs=(
    "/Interner Speicher/DCIM"
    "/Interner Speicher/DCIM/Screenshots"
    "/Interner Speicher/Documents"
    "/Interner Speicher/Download"
    "/Interner Speicher/Movies"
    "/Interner Speicher/Pictures"
    "/Interner Speicher/Android/media/com.whatsapp/WhatsApp/Media"
    "/Interner Speicher (Dual Messenger)/Android/media/com.whatsapp/WhatsApp/Media"
)

exclude_list=("Private/" "Sent/" "Obsidian/" 'Documentos y digitalizaciones/' "Kee/" ".thumbnails/" "APN/" ".Thumbs" ".trash" ".StickerThumbs" "WhatsApp Stickers")

rsync_exclude=()

for exc in "${exclude_list[@]}"; do
    rsync_exclude+=("--exclude=${exc}")
done

if [ -n "$(ls -A "$OUTPUT")" ]; then
    while true; do
        echo -en "\e[1m\e[31m"
        echo "Output directory has files inside."
        echo -en "\e[0m"
        echo -n "Do you want to continue anyway? ["
        echo -n "y/N"
        echo -n "] "
        read -r ans

        case ${ans,,} in
            [y]*) break ;;
            [n]*) ;;
            *) echo "Please enter 'y' or 'n'." ;;
        esac
    done
fi

for folder in "${phone_dirs[@]}"; do
    rsync -va "${rsync_exclude[@]}" "${PHONE}/${folder}" "$OUTPUT"
done

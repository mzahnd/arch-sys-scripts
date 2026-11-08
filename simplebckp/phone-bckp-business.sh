#!/usr/bin/env bash

readonly OUTPUT="${HOME}/Documents/Telefonino_mart/"
readonly PHONE="/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_R58W4148F8M/" # Galaxy A24 Business

# Relative to $PHONE
phone_dirs=(
    "/Spazio di archiviazione interno/DCIM"
    "/Spazio di archiviazione interno/DCIM/Screenshots"
    "/Spazio di archiviazione interno/Documents"
    "/Spazio di archiviazione interno/Download"
    "/Spazio di archiviazione interno/Movies"
    "/Spazio di archiviazione interno/Pictures"
    "/Spazio di archiviazione interno/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Animated Gifs"
    "/Spazio di archiviazione interno/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents"
    "/Spazio di archiviazione interno/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images"
    "/Spazio di archiviazione interno/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video"
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

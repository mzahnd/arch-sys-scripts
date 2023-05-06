#!/bin/bash

readonly OUTPUT="${HOME}/Documents/Telefonino/"
readonly PHONE="/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_R58RA11X8AJ/" # Galaxy A22

# Relative to $PHONE
phone_dirs=(\
    "/Memoria interna/DCIM/Screenshots" \
    "/Memoria interna/Documents" \
    "/Memoria interna/Download" \
    "/Memoria interna/Movies" \
    "/Memoria interna/Pictures/Telegram" \
    "/Memoria interna/Android/data/org.telegram.messenger/files/Pictures" \
    "/Memoria interna/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Animated Gifs" \
    "/Memoria interna/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents" \
    "/Memoria interna/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images" \
    "/Memoria interna/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video" \
    "/Memoria interna (Doppio Account)/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Animated Gifs" \
    "/Memoria interna (Doppio Account)/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents" \
    "/Memoria interna (Doppio Account)/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images" \
    "/Memoria interna (Doppio Account)/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video" \
    "/Scheda SD/DCIM" \
)

exclude_list=("Private/" "Sent/" "Obsidian/")

rsync_exclude=""

for exc in "${exclude_list[@]}"; do
    rsync_exclude="${rsync_exclude} --exclude=${exc}"
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
            [y]*) break;;
            [n]*) ;;
            *) echo "Please enter 'y' or 'n'." ;;
        esac
    done
fi

for folder in "${phone_dirs[@]}"; do
    rsync -va ${rsync_exclude} "${PHONE}/${folder}" "$OUTPUT"
done


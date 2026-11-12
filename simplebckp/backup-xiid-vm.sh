#!/usr/bin/env bash
set -euo pipefail

BACKUPS_DIR='/home/seabmo/vms/backups'

DISK_IMG='/home/seabmo/vms/archlinux-xiid.qcow2'
VM_NAME='xiid'

TODAY="$(date '+%Y-%m-%d')"
BACKUPS_DIR_VM="${BACKUPS_DIR}/${VM_NAME}"
XML_FILE="${BACKUPS_DIR_VM}/${VM_NAME}.xml"
OUTPUT="${BACKUPS_DIR_VM}/${VM_NAME}-${TODAY}.tar.zst"

mkdir -p "${BACKUPS_DIR_VM}"

if ! sudo virsh dumpxml "${VM_NAME}" > "${XML_FILE}" ; then
    echo "ERROR: Failed to dump XML for ${VM_NAME}" >&2
    exit 1
fi

if [[ ! -s "${XML_FILE}" ]]; then
    echo "ERROR: File ${XML_FILE} not be created" >&2
    exit 1
fi

sudo tar -cvf - \
    -C "$(dirname "${XML_FILE}")" "$(basename "${XML_FILE}")" \
    -C "$(dirname "${DISK_IMG}")" "$(basename "${DISK_IMG}")" \
    | zstd -T0 -o "${OUTPUT}"

echo "OK. Created ${OUTPUT}"

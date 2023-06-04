#!/usr/bin/env bash

readonly OUT_DISK="/run/media/seabmo/DiscPMirror/"
readonly IN_DISK="/run/media/seabmo/DiscoPort/" 
readonly LOG_FILE="diskmirror.log"

exclude_list=(\
    ".Trash-[0-9]*/" \
    ".git/" \
)

# --archive is: -rlptgoD
#   -r: --recursive             recurse into directories
#   -l: --links                 copy symlinks as symlinks
#   -p: --perms                 preserve permissions
#   -t: --times                 preserve modification times
#   -g: --group                 preserve group
#   -o: --owner                 preserve owner (super-user only)
#   -D:                         same as --devices --specials
#       --devices:                  preserve device files (super-user only)
#       --specials                  preserve special files
flags=(\
    "--info=flist0,misc1,progress2,stats3" \
    "--archive" \
    "--delete"  \
    "--delete-delay" \
    "--stats"   \
    "--human-readable" \
    "--progress" \
    "--log-file=${LOG_FILE}" \
)


rsync_exclude=""
for exc in "${exclude_list[@]}"; do
    rsync_exclude="${rsync_exclude} --exclude=${exc}"
done

rsync_flags=""
for flag in "${flags[@]}"; do
    rsync_flags="${rsync_flags} ${flag}"
done

rsync ${rsync_flags} ${rsync_exclude} "$IN_DISK" "$OUT_DISK"

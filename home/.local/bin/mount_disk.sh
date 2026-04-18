#!/bin/bash

DISK_NAME='nvme0n1p2'
DISK='/dev/nvme0n1p2'
SYMLINK="${HOME}/windows_fs_mount_point"

if lsblk | grep -q "$DISK_NAME"; then
    MOUNT_OUTPUT=$(udisksctl mount -b "$DISK" 2>&1)

    if [ $? -ne 0 ]; then
        echo "mount error: $MOUNT_OUTPUT"
        exit 1
    fi

    MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep -oP 'at\s+\K.*')

    if [ -z "$MOUNT_POINT" ]; then
        echo "Failed to detect mount point"
        exit 1
    fi

    [ -L "$SYMLINK" ] && rm "$SYMLINK"

    ln -s "$MOUNT_POINT" "$SYMLINK"

    echo "ln -s $MOUNT_POINT $SYMLINK"
else
    echo "Disk ${DISK} not found!"
fi

echo "Mount done!"

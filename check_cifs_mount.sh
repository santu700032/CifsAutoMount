#!/bin/bash

MOUNT_POINT="/mnt/appdatalocal"

if mountpoint -q "$MOUNT_POINT"; then
    logger "CIFS_MOUNT: $MOUNT_POINT already mounted"
    exit 0
fi

logger "CIFS_MOUNT: Share not mounted. Attempting mount."

mount -t cifs \
//day011919154726.file.core.windows.net/fsshare1 \
/mnt/appdatalocal \
-o vers=3.0,credentials=/etc/smbcredentials/appdatalocal.cred,dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30

if mountpoint -q "$MOUNT_POINT"; then
    logger "CIFS_MOUNT: Mount successful"
    exit 0
else
    logger "CIFS_MOUNT: Mount failed"
    exit 1
fi

#!/bin/bash

###############################################################################
# Script Name : check_cifs_mount.sh
# Purpose     : Verify CIFS mounts and automatically remount if missing
# Author      : Santu Bera
# Usage       : Executed by systemd service/timer
#
# Configuration File Format:
# SHARE|MOUNTPOINT|CREDENTIAL_FILE
#
# Example:
# //storageacct.file.core.windows.net/share1|/mnt/share1|/etc/smbcredentials/share1.cred
# //storageacct.file.core.windows.net/share2|/mnt/share2|/etc/smbcredentials/share2.cred
#
###############################################################################

# Configuration file containing CIFS mount details
CONFIG="/etc/cifs-monitor/mounts.conf"

# Log file for script activities
LOGFILE="/var/log/cifs_monitor.log"

###############################################################################
# Function: log_msg
# Purpose : Write messages to local logfile and system journal
###############################################################################

log_msg() {
    echo "$(date '+%F %T') : $1" >> "$LOGFILE"
    logger -t CIFS_MONITOR "$1"
}

###############################################################################
# Validate configuration file existence
###############################################################################

if [ ! -f "$CONFIG" ]; then
    log_msg "ERROR: Configuration file $CONFIG not found"
    exit 1
fi

###############################################################################
# Read each CIFS mount entry from configuration file
###############################################################################

while IFS='|' read -r SHARE MOUNTPOINT CREDS
do

    # Skip blank lines
    [ -z "$SHARE" ] && continue

    # Skip commented lines
    [[ "$SHARE" =~ ^# ]] && continue

    log_msg "Checking mount point $MOUNTPOINT"

    ###########################################################################
    # Verify whether mount already exists
    ###########################################################################

    if mountpoint -q "$MOUNTPOINT"
    then
        log_msg "$MOUNTPOINT already mounted"
        continue
    fi

    ###########################################################################
    # Mount missing - attempt remount
    ###########################################################################

    log_msg "$MOUNTPOINT not mounted. Attempting mount."

    mount -t cifs "$SHARE" "$MOUNTPOINT" -o vers=3.0,credentials="$CREDS",dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30

    ###########################################################################
    # Verify mount status after mount attempt
    ###########################################################################

    if mountpoint -q "$MOUNTPOINT"
    then
        log_msg "$MOUNTPOINT mount successful"
    else
        log_msg "ERROR: $MOUNTPOINT mount failed"
    fi

done < "$CONFIG"

exit 0

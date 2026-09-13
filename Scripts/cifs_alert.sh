#!/bin/bash

###############################################################################
# Script Name : cifs_alert.sh
# Author      : Santu Bera
# Purpose     : Monitor CIFS mounts and send email notifications for
#               mount failures and recoveries.
#
# Features:
#   - Supports multiple CIFS mounts from configuration file
#   - Sends a single alert per outage
#   - Sends recovery notification when mount returns
#   - Prevents alert flooding using state files
#   - Verifies mount accessibility using ls command
#
# Configuration File Format:
# SHARE|MOUNTPOINT|CREDENTIAL_FILE
#
# Example:
# //storageacct.file.core.windows.net/share1|/mnt/share1|/etc/smbcredentials/share1.cred
#
###############################################################################

# Configuration file containing CIFS mount definitions
CONFIG="/etc/cifs-monitor/mounts.conf"

# Directory used to track alert state
ALERTDIR="/var/tmp/cifs_alerts"

# Email recipient
EMAIL=<Provide mail account>

# Create alert directory if it does not already exist
mkdir -p "$ALERTDIR"

# Server information
HOSTNAME=$(hostname)
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
UPTIME=$(uptime -p)
CURRENT_TIME=$(date)

###############################################################################
# Function : send_failure_mail
# Purpose  : Send email when CIFS mount becomes unavailable
###############################################################################
send_failure_mail() {

CURRENT_TIME=$(date)

/usr/sbin/sendmail -t <<EOF
To: $EMAIL
Subject: [CRITICAL] CIFS Mount Failure - $HOSTNAME
MIME-Version: 1.0
Content-Type: text/html

<html>
<body style="font-family:Segoe UI,Arial,sans-serif;background:#f4f6f8;padding:20px;">

<div style="max-width:850px;margin:auto;background:white;border:1px solid #dcdcdc;border-radius:8px;overflow:hidden;">

<div style="background:#c62828;color:white;padding:15px;font-size:22px;font-weight:bold;">
🚨 CIFS Mount Failure Alert
</div>

<div style="padding:20px;">

<p>Hello Team,</p>

<p>
A monitored CIFS mount is currently unavailable and requires investigation.
</p>

<table style="border-collapse:collapse;width:100%;font-size:14px;" border="1">
<tr style="background:#1565c0;color:white;">
<th style="padding:10px;">Parameter</th>
<th style="padding:10px;">Value</th>
</tr>

<tr>
<td><b>Server</b></td>
<td>$HOSTNAME</td>
</tr>

<tr>
<td><b>Server IP</b></td>
<td>$SERVER_IP</td>
</tr>

<tr>
<td><b>System Uptime</b></td>
<td>$UPTIME</td>
</tr>

<tr>
<td><b>Share</b></td>
<td>$SHARE</td>
</tr>

<tr>
<td><b>Mount Point</b></td>
<td>$MOUNTPOINT</td>
</tr>

<tr>
<td><b>Alert Time</b></td>
<td>$CURRENT_TIME</td>
</tr>

<tr>
<td><b>Status</b></td>
<td style="color:#c62828;font-weight:bold;">
FAILED
</td>
</tr>

</table>

<br>

<div style="background:#ffebee;border-left:5px solid #c62828;padding:12px;">
<b>Recommended Checks:</b>
<ul>
<li>Verify network connectivity.</li>
<li>Verify Azure File Share availability.</li>
<li>Verify DNS name resolution.</li>
<li>Check CIFS credentials file.</li>
<li>Review system and mount logs.</li>
<li>Validate storage account accessibility.</li>
</ul>
</div>

<br>

<div style="color:#666;font-size:12px;">
Generated automatically by CIFS Monitoring Service.
</div>

</div>

</div>

</body>
</html>
EOF
}

###############################################################################
# Function : send_recovery_mail
# Purpose  : Send email when CIFS mount becomes accessible again
###############################################################################
send_recovery_mail() {

CURRENT_TIME=$(date)

/usr/sbin/sendmail -t <<EOF
To: $EMAIL
Subject: [RESOLVED] CIFS Mount Recovery - $HOSTNAME
MIME-Version: 1.0
Content-Type: text/html

<html>
<body style="font-family:Segoe UI,Arial,sans-serif;background:#f4f6f8;padding:20px;">

<div style="max-width:850px;margin:auto;background:white;border:1px solid #dcdcdc;border-radius:8px;overflow:hidden;">

<div style="background:#2e7d32;color:white;padding:15px;font-size:22px;font-weight:bold;">
✅ CIFS Mount Recovery Notification
</div>

<div style="padding:20px;">

<p>Hello Team,</p>

<p>
The previously failed CIFS mount has recovered and is accessible again.
</p>

<table style="border-collapse:collapse;width:100%;font-size:14px;" border="1">
<tr style="background:#1565c0;color:white;">
<th style="padding:10px;">Parameter</th>
<th style="padding:10px;">Value</th>
</tr>

<tr>
<td><b>Server</b></td>
<td>$HOSTNAME</td>
</tr>

<tr>
<td><b>Server IP</b></td>
<td>$SERVER_IP</td>
</tr>

<tr>
<td><b>System Uptime</b></td>
<td>$UPTIME</td>
</tr>

<tr>
<td><b>Share</b></td>
<td>$SHARE</td>
</tr>

<tr>
<td><b>Mount Point</b></td>
<td>$MOUNTPOINT</td>
</tr>

<tr>
<td><b>Recovery Time</b></td>
<td>$CURRENT_TIME</td>
</tr>

<tr>
<td><b>Status</b></td>
<td style="color:#2e7d32;font-weight:bold;">
RECOVERED
</td>
</tr>

</table>

<br>

<div style="background:#e8f5e9;border-left:5px solid #2e7d32;padding:12px;">
<b>Resolution Summary</b><br>
The CIFS mount is now accessible and operating normally.
No further action is currently required.
</div>

<br>

<div style="color:#666;font-size:12px;">
Generated automatically by CIFS Monitoring Service.
</div>

</div>

</div>

</body>
</html>
EOF
}

###############################################################################
# Process each mount defined in configuration file
###############################################################################
while IFS='|' read -r SHARE MOUNTPOINT CREDS
do

    # Skip blank lines
    [ -z "$SHARE" ] && continue

    # Skip comments
    [[ "$SHARE" =~ ^# ]] && continue

    # Alert state file used to suppress duplicate alerts
    ALERTFILE="$ALERTDIR/$(basename "$MOUNTPOINT").alerted"

    ###########################################################################
    # Check whether mount exists and is accessible
    ###########################################################################
    if mountpoint -q "$MOUNTPOINT" && timeout 10 ls "$MOUNTPOINT" >/dev/null 2>&1
    then

        # Mount recovered
        if [ -f "$ALERTFILE" ]
        then
            send_recovery_mail
            rm -f "$ALERTFILE"
        fi

    else

        # Mount failed
        if [ ! -f "$ALERTFILE" ]
        then
            send_failure_mail
            touch "$ALERTFILE"
        fi

    fi

done < "$CONFIG"

exit 0

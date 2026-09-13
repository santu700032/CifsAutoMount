# 🚀 CIFS Self-Healing Monitoring & Alerting Solution

> Automated CIFS/SMB Mount Recovery, Monitoring & Email Alerting Framework for Linux Servers

---

## 📌 Project Overview

This project automates the monitoring and recovery of CIFS/SMB mounts on Linux servers.

The solution:

✅ Detects CIFS mount failures

✅ Automatically remounts unavailable shares

✅ Sends HTML email alerts for failures

✅ Sends recovery notifications

✅ Prevents duplicate email alerts

✅ Supports multiple CIFS shares

✅ Maintains centralized logs

---

## 🏗️ Architecture

```text
Azure File Shares
 │
 ▼
 Linux Server
 │
 ┌──────┴──────┐
 │ │
 ▼ ▼

check_cifs_ cifs_alert
mount.sh .sh

 │ │
 ▼ ▼

Auto Email Alerts
Recovery & Monitoring
```

---

## ⭐ Key Features

### 🔧 Auto Recovery

- Verifies CIFS mount availability
- Detects missing mounts
- Automatically remounts shares
- Logs all mount activities

### 📧 Email Alerting

- Failure Notifications
- Recovery Notifications
- HTML Email Formatting
- Red/Green Status Indicators

### 🛡️ Alert Suppression

- Prevents duplicate alerts
- Uses state files (`*.alerted`)
- One failure email per outage
- One recovery email per restoration

### 📊 Monitoring

- Real-time mount validation
- Cron based health checks
- Systemd based mount recovery
- Multiple share support

---

## 📂 Project Structure

```text
/etc/cifs-monitor/
└── mounts.conf

/usr/local/bin/
├── check_cifs_mount.sh
└── cifs_alert.sh

/etc/systemd/system/
├── cifsshare_mount.service
└── cifsshare_mount.timer

/etc/smbcredentials/
└── *.cred

/var/log/
├── cifs_monitor.log
└── cifs_alert.log

/var/tmp/cifs_alerts/
└── *.alerted
```

---

## ⚙️ Configuration

### mounts.conf

```text
SHARE|MOUNTPOINT|CREDENTIAL_FILE
```

Example:

```text
//storage.share1|/mnt/appdatalocal|/etc/smbcredentials/appdatalocal.cred
//storage.share2|/mnt/transactiondata|/etc/smbcredentials/transactiondata.cred
//storage.share3|/mnt/backupdata|/etc/smbcredentials/backupdata.cred
```

---

## 🔄 Failure & Recovery Flow

### 🔴 Failure Workflow

```text
Mount Down
 │
 ▼
.alerted Exists?
 │
 No
 │
 ▼
Send Failure Email
 │
 ▼
Create .alerted
```

### 🟢 Recovery Workflow

```text
Mount Restored
 │
 ▼
.alerted Exists?
 │
 Yes
 │
 ▼
Send Recovery Email
 │
 ▼
Remove .alerted
```

---

## ⏰ Scheduling

### Systemd Timer

```ini
OnBootSec=5min
OnUnitActiveSec=30min
```

### Cron Monitoring

```cron
*/5 * * * * /usr/local/bin/cifs_alert.sh >/dev/null 2>&1
```

---

## 📝 Logs

### Mount Monitoring Log

```text
/var/log/cifs_monitor.log
```

### Alert Log

```text
/var/log/cifs_alert.log
```

---

## 🧪 Testing Completed

✅ Mount Verification

✅ Auto Remount

✅ Failure Email Alert

✅ Recovery Email Alert

✅ Cron Execution

✅ HTML Email Rendering

✅ Duplicate Alert Suppression

✅ Multiple CIFS Share Monitoring

✅ Systemd Timer Validation

---

## 🔒 Security

✅ Separate Credential Files

✅ Restricted Permissions (`600`)

✅ Root Ownership

✅ No Password Logging

---

## 🎯 Benefits

- Reduced Manual Intervention
- Faster Incident Detection
- Automatic Recovery
- Improved Storage Availability
- Scalable Multi-Share Monitoring
- Production Ready Solution

---

## 🚀 Future Enhancements

- Storage Capacity Monitoring
- Threshold Based Alerts (80/90/95%)
- CIFS Latency Monitoring
- Grafana Dashboard
- Prometheus Integration
- Historical Reporting

---

## 📌 Project Status

✅ Developed

✅ Tested

✅ Validated

✅ Production Ready

---

### 👨‍💻 Author

**Santu Bera**

**Linux Infrastructure Automation Project**

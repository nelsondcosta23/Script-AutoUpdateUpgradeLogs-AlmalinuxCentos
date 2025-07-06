# Update & Notification Script for AlmaLinux 9

This script automates system maintenance for **AlmaLinux 9** by:

- Performing system updates via `dnf`
- Checking if a reboot is required
- Sending a detailed report via email using `msmtp`
- Saving local logs with timestamped filenames

---

## Features

- Automated system update and cleanup
- Reboot detection
- Email notification with full log content
- Local log storage (`/logs/`)
- Cron-job friendly

---

## 1. Install Required Packages

```bash
sudo dnf install -y epel-release
sudo dnf update -y
sudo dnf install -y msmtp sharutils dnf-utils
```

## 2. Configure `msmtp`

Create the configuration file:

```bash
nano ~/.msmtprc
```

Update the configuration file with your email details:
```bash
defaults
auth           on
tls            on
tls_starttls   off
tls_trust_file /etc/ssl/certs/ca-bundle.crt
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           465
from           noreply@demo.com
user           your-gmail-account@gmail.com
password       your_app_password

account default : gmail
```

Give permission to the .msmtprc file:
```bash
chmod 600 ~/.msmtprc
```

Test if the service is working. Don't forget to change the To: and From: fields:
```bash
echo -e "To: your_email@example.com\nFrom: noreply@demo.com\nSubject: MSMTP Test\n\nThis is a test email." | msmtp --debug your_email@example.com
```

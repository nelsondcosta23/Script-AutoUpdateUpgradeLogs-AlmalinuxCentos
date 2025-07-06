## 🔄 AutoUpdate & Notification Script for AlmaLinux

Keep your server healthy, updated, and under control — effortlessly.

This script checks for system updates, applies them when needed, logs everything neatly, and emails you a full report — whether updates were installed, skipped, or if something failed. It even reboots the system **only when necessary**, and always after emailing you first.

No more logging in just to run `dnf update`. Automate it, track it, and stay informed — with style.

Perfect for sysadmins who love clean logs, smart automation, and peace of mind.

---

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

## 3. Setup Cronjob

```bash
sudo crontab -e
```

Add your timer:
```bash
0 4 1 */2 * /root/Script-AutoUpdateUpgradeLogs-AlmalinuxCentos/Update.sh
```

Confirm you time:
```bash
chmod +x /root/Script-AutoUpdateUpgradeLogs-AlmalinuxCentos/Update.sh
```

Check logs
```bash
journalctl -u crond
# ou
grep CRON /var/log/cron
```

Check if its working
```bash
/root/Script-AutoUpdateUpgradeLogs-AlmalinuxCentos/Update.sh
```


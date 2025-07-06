#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%M-%H-%d-%m-%Y")
LOG_DIR="/root/logs"
LOG_FILE="$LOG_DIR/update_upgrade_$TIMESTAMP.log"
EMAIL="your_email@example.com"
SUBJECT="System Update Report - $TIMESTAMP"
HOSTNAME=$(hostname)
TMPMAIL="/tmp/mail_$TIMESTAMP.txt"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Start logging
{
    echo "===== System Update Report for $HOSTNAME ====="
    echo "Date: $(date)"
    echo "----------------------------------------------"

    echo ">> Running: dnf update -y"
    sudo dnf update -y

    echo ">> Cleaning up"
    sudo dnf autoremove -y
    sudo dnf clean all

    echo ">> Checking if reboot is required"
    if [ -f /var/run/reboot-required ] || needs-restarting -r > /dev/null 2>&1; then
        echo "Reboot is required. The system will reboot after the email is sent."
        REBOOT_REQUIRED=true
    else
        echo "No reboot is required."
        REBOOT_REQUIRED=false
    fi

    echo ">> Final status: SUCCESS"
    STATUS="SUCCESS"
} &> "$LOG_FILE" || {
    STATUS="FAILURE"
    echo "Errors occurred during the execution." >> "$LOG_FILE"
}

# Build the email message
{
    echo "To: $EMAIL"
    echo "From: noreply@demo.com"
    echo "Subject: $SUBJECT - $STATUS"
    echo ""
    cat "$LOG_FILE"
} > "$TMPMAIL"

# Send the email
cat "$TMPMAIL" | msmtp "$EMAIL"

# Remove temporary mail file
rm -f "$TMPMAIL"

# Reboot if required
if [ "$REBOOT_REQUIRED" = true ]; then
    sudo reboot
fi

exit 0

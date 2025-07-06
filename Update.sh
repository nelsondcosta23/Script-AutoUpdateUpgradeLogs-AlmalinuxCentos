#!/bin/bash

# Get the directory where this script is located
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$BASE_DIR/logs"
TIMESTAMP=$(date +"%M-%H-%d-%m-%Y")
LOG_FILE="$LOG_DIR/update_upgrade_$TIMESTAMP.log"
TMPMAIL="/tmp/mail_$TIMESTAMP.txt"

EMAIL="nelsonfilipecosta@gmail.com"
SUBJECT="System Update Report - $TIMESTAMP"
HOSTNAME=$(hostname)

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Initialize reboot flag
REBOOT_REQUIRED=false

# Start logging
echo "===== System Update Report for $HOSTNAME =====" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "----------------------------------------------" >> "$LOG_FILE"

# Check if updates are available
dnf check-update --quiet > /dev/null 2>&1
AVAILABLE_UPDATES=$?
if [ "$AVAILABLE_UPDATES" -ne 100 ]; then
    STATUS="NOTHING TO UPDATE"
    echo "No updates available. System is up to date." >> "$LOG_FILE"
else
    # Perform update
    {
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
        fi

        STATUS="SUCCESS"
        echo ">> Final status: $STATUS"
    } >> "$LOG_FILE" 2>&1 || {
        STATUS="FAILURE"
        echo "Errors occurred during the execution." >> "$LOG_FILE"
    }
fi

# Build email message
{
    echo "To: $EMAIL"
    echo "From: noreply@demo.com"
    echo "Subject: $SUBJECT - $STATUS"
    echo ""
    cat "$LOG_FILE"
} > "$TMPMAIL"

# Send the email
if cat "$TMPMAIL" | msmtp "$EMAIL" 2>> "$LOG_FILE"; then
    echo "[INFO] Email successfully sent to $EMAIL." >> "$LOG_FILE"
else
    echo "[ERROR] Failed to send email to $EMAIL." >> "$LOG_FILE"
fi

# Clean up
rm -f "$TMPMAIL"

# Reboot if needed
if [ "$REBOOT_REQUIRED" = true ]; then
    echo "Rebooting system now..." >> "$LOG_FILE"
    sudo reboot
fi

exit 0

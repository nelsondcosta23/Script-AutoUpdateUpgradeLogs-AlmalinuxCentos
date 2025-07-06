#!/bin/bash

# Get the directory where this script is located
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$BASE_DIR/logs"
TIMESTAMP=$(date +"%M-%H-%d-%m-%Y")
LOG_FILE="$LOG_DIR/update_upgrade_$TIMESTAMP.log"
TMPMAIL="/tmp/mail_$TIMESTAMP.txt"

EMAIL="your_email@example.com"
SUBJECT="System Update Report - $TIMESTAMP"
HOSTNAME=$(hostname)

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Check if updates are available
AVAILABLE_UPDATES=$(dnf check-update --quiet; echo $?)
if [ "$AVAILABLE_UPDATES" -ne 100 ]; then
    STATUS="NOTHING TO UPDATE"
    {
        echo "===== System Update Report for $HOSTNAME ====="
        echo "Date: $(date)"
        echo "----------------------------------------------"
        echo "No updates available. System is up to date."
    } > "$LOG_FILE"

    {
        echo "To: $EMAIL"
        echo "From: noreply@demo.com"
        echo "Subject: $SUBJECT - $STATUS"
        echo ""
        cat "$LOG_FILE"
    } > "$TMPMAIL"

    cat "$TMPMAIL" | msmtp "$EMAIL"
    rm -f "$TMPMAIL"
    exit 0
fi

# Run the update process
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

# Build and send the email
{
    echo "To: $EMAIL"
    echo "From: noreply@demo.com"
    echo "Subject: $SUBJECT - $STATUS"
    echo ""
    cat "$LOG_FILE"
} > "$TMPMAIL"

cat "$TMPMAIL" | msmtp "$EMAIL"
rm -f "$TMPMAIL"

# Reboot if needed
if [ "$REBOOT_REQUIRED" = true ]; then
    sudo reboot
fi

exit 0

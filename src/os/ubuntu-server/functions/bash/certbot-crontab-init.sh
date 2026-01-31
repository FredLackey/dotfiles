#!/bin/bash
# Add certbot renewal cron job if it doesn't already exist.
#
# Usage:
#   certbot-crontab-init

certbot-crontab-init() {
    local cron_line="0 12 * * * /usr/bin/certbot renew --quiet"
    local temp_crontab
    local cron_service="cron"

    # Determine cron service name based on OS
    if [[ -f /etc/redhat-release ]]; then
        cron_service="crond"
    fi

    # Check if cron service is running
    echo "Checking cron service status..."
    if ! systemctl is-active --quiet "$cron_service"; then
        echo "Cron service ($cron_service) is not running"
        echo "Attempting to start and enable cron service..."

        if ! sudo -v; then
            echo "Error: sudo authentication failed"
            return 1
        fi

        if sudo systemctl start "$cron_service" && sudo systemctl enable "$cron_service"; then
            echo "Cron service started and enabled successfully"
        else
            echo "Failed to start cron service"
            return 1
        fi
    else
        echo "Cron service ($cron_service) is running"
    fi

    echo "Checking for existing certbot renewal cron job..."

    # Get current crontab
    temp_crontab=$(crontab -l 2>/dev/null)
    local crontab_exists=$?

    # Check if the certbot renewal line already exists
    if [[ $crontab_exists -eq 0 ]] && echo "$temp_crontab" | grep -Fq "/usr/bin/certbot renew --quiet"; then
        echo "Certbot renewal cron job already exists"
        echo "Current crontab entries containing 'certbot':"
        echo "$temp_crontab" | grep certbot
        return 0
    fi

    echo "Adding certbot renewal cron job..."

    # Create new crontab content
    if [[ $crontab_exists -eq 0 && -n "$temp_crontab" ]]; then
        {
            echo "$temp_crontab"
            echo "$cron_line"
        } | crontab -
    else
        echo "$cron_line" | crontab -
    fi

    if [[ $? -eq 0 ]]; then
        echo "Certbot renewal cron job added successfully!"
        echo "Added: $cron_line"
        echo ""
        echo "This will automatically renew SSL certificates daily at 12:00 PM."
        echo "You can view your current crontab with: crontab -l"
    else
        echo "Failed to add certbot renewal cron job"
        return 1
    fi
}

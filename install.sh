#!/bin/bash

# Configure to use Systemd Service
enable_systemd="no" # "yes" or "no"

# Install Script into the required folders
cp bin/fix-stale-handle /usr/local/bin/fix-stale-handle

# Copy Crontab File
cp cron/fix-stale-handle /etc/cron.d/fix-stale-handle

if [[ ${enable_systemd} == "no" ]]
then
     # If already installed remove Service File and disable Service itself
     if [[ -f "/etc/systemd/system/fix-stale-handle.service" ]]
     then
          # Remove Service File
          rm -f /etc/systemd/system/fix-stale-handle.service

          # Reload Daemon
          systemctl daemon-reload

          # Stop Daemon
          systemctl stop fix-stale-handle.service

          # Disable Daemon
          systemctl disable fix-stale-handle.service
     fi
elif [[ ${enable_systemd} == "yes" ]]
     # Install Systemd Service
     cp systemd/fix-stale-handle.service /etc/systemd/system/fix-stale-handle.service

     # Reload Systemd Daemon
     systemctl daemon-reload

     # Enable Systemd Service
     systemctl enable fix-stale-handle.service

     # Start Systemd Service
     systemctl restart fix-stale-handle.service
else
     # Invalid Configuration Option
     echo "Invalid Configuration Option for <enable_systemd>. Aborting !"
     exit 1
fi

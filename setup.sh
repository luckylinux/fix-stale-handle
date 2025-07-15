#!/bin/bash

# Input Argument
scheduler=${1-""}

while [ "${scheduler}" != "systemd" ] && [ "${scheduler}" != "cron" ]
do
    # Ask User interactively
    read -p "Enter the Scheduler Manager to use [systemd/cron]: " scheduler
done

# Configure to use Systemd Service
enable_systemd="no" # "yes" or "no"

# Install Script into the required folders
cp bin/fix-stale-handle /usr/local/bin/fix-stale-handle

if [[ "${scheduler}" == "cron" ]]
then
     # Copy Crontab File
     cp cron/fix-stale-handle /etc/cron.d/fix-stale-handle

     # If already installed, remove Timer File and disable Timer itself
     if [[ -f "/etc/systemd/system/fix-stale-handle.timer" ]]
     then
          # Stop Timer
          systemctl stop fix-stale-handle.timer

          # Disable Timer
          systemctl disable fix-stale-handle.timer

          # Remove Systemd Timer File
          rm -f /etc/systemd/system/fix-stale-handle.timer
     fi

     # If already installed, remove Service File and disable Service itself
     if [[ -f "/etc/systemd/system/fix-stale-handle.service" ]]
     then
          # Stop Service
          systemctl stop fix-stale-handle.service

          # Disable Service
          systemctl disable fix-stale-handle.service

          # Remove Systemd Service File
          rm -f /etc/systemd/system/fix-stale-handle.service
     fi

     # Reload Systemd Daemon
     systemctl daemon-reload
elif [[ "${scheduler}" == "systemd" ]]
then
     # Install Systemd Service
     cp systemd/fix-stale-handle.service /etc/systemd/system/fix-stale-handle.service

     # Install Systemd Timer
     cp systemd/fix-stale-handle.timer /etc/systemd/system/fix-stale-handle.timer

     # Reload Systemd Daemon
     systemctl daemon-reload

     # Enable Systemd Service
     systemctl enable fix-stale-handle.service

     # Start Systemd Service
     systemctl restart fix-stale-handle.service

     # Enable Systemd Timer
     systemctl enable fix-stale-handle.timer

     # Start Systemd Timer
     systemctl restart fix-stale-handle.timer

     # Remove Cron File
     if [[ -f "/etc/cron.d/fix-stale-handle" ]]
     then
        rm /etc/cron.d/fix-stale-handle
     fi
else
     # Invalid Configuration Option
     echo "Invalid Configuration Option for <enable_systemd>. Aborting !"
     exit 1
fi

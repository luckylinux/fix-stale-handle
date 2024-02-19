#!/bin/bash

# Install Script into the required folders
cp bin/fix-stale-handle /usr/local/bin/fix-stale-handle

# Install Systemd Service
cp systemd/fix-stale-handle.service /etc/systemd/system/fix-stale-handle.service

# Reload Systemd Daemon
systemctl daemon-reload

# Enable Systemd Service
systemctl enable fix-stale-handle.service

# Start Systemd Service
systemctl restart fix-stale-handle.service

# Copy Crontab File
cp cron/fix-stale-handle /etc/cron.d/fix-stale-handle

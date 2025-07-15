# Introduction
Detect and Fix NFS Stale Handle, that can occur due to e.g.:
- Networking Problems
- NFS Server Restarting/Rebooting

# Installation
## With CRON
```
./setup.sh cron
```

## With Systemd
```
./setup.sh systemd
```

# Working Principle
For each of the NFS shares, it tests whether the mountpoint is `Stale File Handle`, a regular list of files or if the scan command times-out (which results in the assumption of a `Stale File Handle` anyway).

If the NFS mount point has been mounted with the `hard` mount option on the client, it typically will cause the command to hang. Thus if the timeout of 10s is reached, it's assumed to be a `Stale File Handle`.

# Crontab
The installer installs a Crontab File in `/etc/cron.d/fix-stale-handle` which executes every 5 minutes and scans for NFS shares.

# Systemd
Systemd has additional Logging Options for easier Debugging compared to Crontab (`journalctl`) and that's done on a per-Service basis.

The installer installs a Systemd Service in `/etc/systemd/system/fix-stale-handle.service`.

The installer installs a Systemd Timer in `/etc/systemd/system/fix-stale-handle.timer`.

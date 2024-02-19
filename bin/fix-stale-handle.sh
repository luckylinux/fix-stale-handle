#!/bin/bash

# Define default timeout
default_timeout=10 # [s]

# Define command
command="ls -l"

# Ignore case in string comparisons
shopt -s nocasematch

# Find all filesystems of type NFS
# Ignore first Line (Field Names) - start at line #2
mapfile -t shares < <( findmnt -l --types nfs --output target | tail --lines +2 )

# For each share
for share in "${shares[@]}"
do
    # Echo
    echo "Processing NFS Share <$share>"

    # Assume it's NOT stale
    stale=0

    # Detection
    description=""

    # Attempt to get list of files in share
    output=$(timeout ${default_timeout}s $command $share)

    # Return code
    ret=$?

    if [[ $ret -eq 124 ]]
    then
        # Command timed out
        # Assume IS stale file handle
        stale=1
        description="Stale file handle assumed"
    elif [[ $ret -eq 137 ]]
    then
        # Command timed out and had to be killed
        # Assume IS stale file handle
        stale=1
        description="Stale file handle assumed"
    elif [[ $ret -eq 0 ]]
    then
        # Command was executed successfully and exit code is normal
        # NOT stale file handle
        stale=0
    else
        # Analyse Output
        # If it contains "stale file handle" then we must also flag the share
        if [[ "$output" =~ "Stale file handle" ]]
        then
             # IS Stale file handle
             stale=1
             description="Stale file handle positively detected"
        fi
    fi

    # Check if Stale
    if [[ $stale -eq 1 ]]
    then
        echo "$description"
        echo "Unmounting $share"
        umount -f -l $share
        sleep 5

        echo "Re-mounting $share"
        mount $share
        sleep 5
    fi
done

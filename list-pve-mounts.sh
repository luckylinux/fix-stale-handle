#!/bin/bash

if [[ -d "/etc/pve" ]]
then
    if [[ -d "/etc/pve/lxc" ]]
    then
        # Get List of Entries
        mapfile -t mount_entries < <( grep -EHri "^lxc.mount.entry:|^mp[0-9]+:" /etc/pve/lxc/ )

        # Loop over Mount Entries
        for mount_entry in "${mount_entries[@]}"
        do
            # Get CT Filename
            pve_ct_filename=$(echo "${mount_entry}" | cut -d: -f 1)

            # Get CT ID
            pve_ct_id=$(basename "${pve_ct_filename}" | sed -E "s|^([0-9]+)\.conf|\1|")

            # Echo
            echo "Analysing Container ID ${pve_ct_id}"

            # Get Type (mp[0-9]+ or lxc.mount.entry)
            mount_type=$(echo "${mount_entry}" | cut -d: -f 2)

            # Echo
            echo -e "\t- mount_type: ${mount_type}"

            # Get Mount Line
            mount_line=$(echo "${mount_entry}" | cut -d: -f 3)

            # Echo
            echo -e "\t- mount_line: ${mount_line}"

            # Get rootfs Line for LXC Container
            rootfs_line=$(cat /etc/pve/lxc/${pve_ct_id}.conf | grep -E "^rootfs: " | awk '{print $2}')

            # Echo
            echo -e "\t- rootfs_line: ${rootfs_line}"

            # Get Storage ID
            storage_id=$(echo "${rootfs_line}" | awk -F":" '{print $1}')

            # Echo
            echo -e "\t- storage_id: ${storage_id}"

            # Get Volume ID
            volume_id=$(echo "${rootfs_line}" | awk -F":" '{print $2}' | awk -F"[,;]" '{print $1}')

            # Echo
            echo -e "\t- volume_id: ${volume_id}"

            # Get ZFS Pool root dataset based on the corresponding local-zfs (or similar) Data Block in /etc/pve/storage.cfg
            zfs_pool_root=$(awk "/zfspool: ${storage_id}/" RS= /etc/pve/storage.cfg | grep -E "\s+pool" | sed -E "s|\s*?pool\s?([a-zA-Z0-9/_-]+)$|\1|g")

            # Echo
            echo -e "\t- zfs_pool_root: ${zfs_pool_root}"

            # Build Countainer ZFS Dataset
            zfs_ct_dataset="${zfs_pool_root}/${volume_id}"

            # Debug
            echo -e "\t- zfs_ct_dataset: ${zfs_ct_dataset}"

            # Build Container ZFS Mountpoint
            zfs_ct_mount_point=$(zfs get -H -o value mountpoint "${zfs_ct_dataset}")

            # Debug
            echo -e "\t- zfs_ct_mount_point: ${zfs_ct_mount_point}"

            # Depending on the mount Type, different Parsing is needed
            if [[ "${mount_type}" == "lxc.mount.entry" ]]
            then
                # lxc.mount.entry
                # Split into fstab-like Arguments
                mapfile -t mount_options < <( echo "${mount_line}" | awk -F" " '{print $1"\n"$2"\n"$3"\n"$4"\n"$5"\n"$6}' )

                # mount_point_source
                mount_point_source="${mount_options[0]}"

                # mount_point_destination
                mount_point_destination="${zfs_ct_mount_point}/${mount_options[1]}"

                # mount_point_fs
                mount_point_fs="${mount_options[2]}"

                # mount_point_opts
                mount_point_opts="${mount_options[3]}"
            elif [[ "${mount_type}" == "mp"* ]]
            then
                # mp[0-9]+
                # Split into fstab-like Arguments
                mapfile -t mount_options < <( echo "${mount_line}" | awk -F"," '{print $1"\n"$2"\n"$3"\n"$4"\n"$5"\n"$6}' )

                # mount_point_source
                mount_point_source="${mount_options[0]}"

                # mount_point_destination
                mount_point_destination="${mount_options[1]}"

                # mount_point_fs
                mount_point_fs="${mount_options[2]}"

                # mount_point_opts
                mount_point_opts="${mount_options[3]}"
            fi

            # Echo
            echo -e "\t- mount_point_source: ${mount_point_source}"
            echo -e "\t- mount_point_destination: ${mount_point_destination}"
            echo -e "\t- mount_point_fs: ${mount_point_fs}"
            echo -e "\t- mount_point_opts: ${mount_point_opts}"
        done

        # Check
        
    fi
fi

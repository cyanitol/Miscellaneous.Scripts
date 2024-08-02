#!/bin/bash
# Copyright 2022 Justin Weeks <license@jmweeks.com>

BKLOG=/path/to/backup.log

echo -e "\n\n\n== Start Backup - $(date) ==" >> $BKLOG

#Uncomment below for detailed logging (restic output saved to log file)
#exec &> "$BKLOG"

export RESTIC_REPOSITORY=b2:reponame:folder/another.folder/
export B2_ACCOUNT_ID=0000000000000000000000000
export B2_ACCOUNT_KEY=0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0
export RESTIC_PASSWORD_FILE=/path/to/.restic-password

restic backup --one-file-system / -o b2.connections=32 --verbose --verbose --exclude="/swapfile"

echo == End Backup - $(date) == >> $BKLOG

#Restore Instructions
# created a VM which is big enough at some cloud provider
#booted it with the provided rescue system
#downloaded restic to /usr/local/bin, checked the repo with restic … snapshots -> worked
#mounted the harddisk at /mnt/restore and did restic restore to that target.
#did a chroot to /mnt/restore, grub2-install, grub2-mkconfig, dracut -f
#changed fstab to the correct UUID
#recreate /swapfile
#umount, reboot
# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/oracle/.vbox_version)
cd /tmp
mount -o loop /home/oracle/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /home/oracle/VBoxGuestAdditions_*.iso


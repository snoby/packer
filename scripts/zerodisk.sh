#
# This is mainly for vmware on the host, but we can shrink the unused
# area of the disk by setting it to all zeros
# For vmware you may have to call vmware-vdiskmanager to shrink the file.
#
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY


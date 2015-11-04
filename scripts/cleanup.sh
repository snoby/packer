# clean up unneeded packages
yum -y clean all
#
# udev will mess us up wiht network device naming
#
rm -f /etc/udev/rules.d/70-persistent-net.rules

#on startup remove HWADDDR from the eth0 interface
cp -f /etc/sysconfig/network-scripts/ifcfg-eth0 /tmp/eth0
sed "/^HWADDR/d" /tmp/eth0 > /etc/sysconfig/network-scripts/ifcfg-eth0



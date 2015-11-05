#!/bin/bash
set -x
echo "Creating user Oracle"


#
# Create the user and group oracle
#
/usr/sbin/groupadd oracle
useradd oracle -g oracle -G wheel
echo "oracle"|passwd --stdin oracle
echo "oracle          ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers.d/oracle
chmod 0440 /etc/sudoers.d/oracle

#
# set the tmp directory up for the oracle user 
#
echo "export TMP=/tmp" >> /home/oracle/.bash_profile
echo "export TMPDIR=/tmp" >> /home/oracle/.bash_profile
echo "export ORACLE_HOSTNAME='$HOSTNAME'" >> /home/oracle/.bash_profile


#!/bin/bash
set -x
#
# This script is expected to run in the packer build environment
# it is expected that the hostname is just localhost.localdomain and
# that the hostname variable has not been set.
#
# The oracle user must also already exist with root privs
#
# Finally we assume that the packer provisioner for file / directory
# uploads has been accomplished.  Basically the db_installer directory
# has been uploaded by packer to the /home/oracle/ directory
#
#



INSTALL_DIR=/home/oracle/db_installer

pushd "${INSTALL_DIR}"

ls -lh

chmod +x oracle_all_in_one_create.sh
chmod +x create_oracle_user.sh
chmod +x install_db_software.sh

sudo su -c ./oracle_all_in_one_create.sh

echo "Cleaning up"
rm -rf "${INSTALL_DIR}/linuxamd64*.zip"
popd



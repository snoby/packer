#!/bin/bash

#
# Must be run as root
#
# Check if run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Create the Oracle user and groups
#
echo "Creating the oracle user"
./create_oracle_user.sh

#
# run the preinstaller
#
oracle-rdbms-server-12cR1-preinstall-verify

#
# call the database installer software script indicating that
# as user oracle
# also indicating the the installer zip files are in this
# location as well
#
echo "Running the install_db_software script from '$PWD'" 

./install_db_software.sh -i "$PWD"

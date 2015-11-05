#!/bin/bash
set -x
#
# DB Software Installation script
# Installs Oracle Database software
#
# Prerequisites:
# - Installed package "oracle-rdbms-server-12cR1-preinstall.rpm"
# - Executed oracle-rdbms-server-12cR1-preinstall-verify
# - Copied GI and DB software (the following archives) to $ORACLE_INSTALLFILES_LOCATION
#   - linuxamd64_*_database_1of2.zip
#   - linuxamd64_*_database_2of2.zip
# - # passwd oracle
#

ORACLE_MOUNTPOINTS=(/u01 /u02 /u03 /u04)

ORACLE_USER=oracle
ORACLE_BASE=${ORACLE_MOUNTPOINTS[0]}/app/oracle
ORACLE_HOME=${ORACLE_BASE}/product/12.1.0/db_1
ORACLE_INVENTORY_LOCATION=/u01/app/oraInventory
ORACLE_INSTALLFILES_LOCATION=/home/oracle
ORACLE_HOSTNAME="$HOSTNAME"
ORACLE_MEMORY_SIZE=2048M

unset LANG

### Script start

usage()
{
cat << EOF
usage: $0 [-h] [-u ORACLE_USER] [-m ORACLE_MEMORY_SIZE] [-i INSTALLFILES_DIR]

This script is used to install Oracle Grid Infrastructure and the Oracle
database software. The default settings will install the database software
according to the OFA standard.

OPTIONS:
   -h      Show this message
   -i      Folder that contains the installation ZIP files. Defaults to "$ORACLE_INSTALLFILES_LOCATION"
   -u      User that owns the Oracle software installation. Defaults to "$ORACLE_USER"
   -m      Aggregate shared memory size for all databases on this machine.
           Defaults to $ORACLE_MEMORY_SIZE.
EOF
}

# Parse arguments
while getopts "hi:u:m:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
             ORACLE_INSTALLFILES_LOCATION=$OPTARG
             ;;
	 u)
	     ORACLE_USER=$OPTARG
	     ;;
	 m)
	     ORACLE_MEMORY_SIZE=$OPTARG
	     ;;
         ?)
             usage
             exit
             ;;
     esac
done

# Check if run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

id $ORACLE_USER 2>/dev/null
if [ $? -eq 0 ]; then
	echo "User $ORACLE_USER found, proceeding..."
else
	echo "User $ORACLE_USER not found, aborting..."
	exit 1
fi

# Check necessary programs installed
which unzip
if [ $? -eq 0 ]; then
	echo "unzip is installed"
else
	echo "unzip not found, aborting..."
	exit 1
fi

which oracle-rdbms-server-12cR1-preinstall-verify
if [ $? -eq 0 ]; then
	echo "oracle-rdbms-server-12cR1-preinstall-verify is installed"
else
	echo "oracle-rdbms-server-12cR1-preinstall-verify not found, aborting..."
	exit 1
fi




# Prepare filesystem

# Make sure the mountpoints exist
# This command will create them as folders if necessary
for mountpoint in ${ORACLE_MOUNTPOINTS[*]}
do
	mkdir -p $mountpoint
	chown -R ${ORACLE_USER}:oinstall $mountpoint
done

mkdir -p ${ORACLE_HOME}
mkdir -p ${ORACLE_INVENTORY_LOCATION}
chown -R ${ORACLE_USER}:oinstall ${ORACLE_BASE}
chown -R ${ORACLE_USER}:oinstall ${ORACLE_INVENTORY_LOCATION}

# Prepare groups and users
groupadd asmadmin
groupadd asmoper
groupadd dgdba
groupadd bckpdba
groupadd kmdba
usermod -a -G dba,asmoper,asmadmin,dgdba,bckpdba,kmdba ${ORACLE_USER}



# Oracle database software
cd ${ORACLE_INSTALLFILES_LOCATION}
unzip ${ORACLE_INSTALLFILES_LOCATION}/linuxamd64_*_database_se2_1of2.zip
unzip ${ORACLE_INSTALLFILES_LOCATION}/linuxamd64_*_database_se2_2of2.zip
chown -R ${ORACLE_USER}:oinstall ${ORACLE_INSTALLFILES_LOCATION}/database
#TODO: Check if everything worked as expected and only remove if no errors occured


cd  ${ORACLE_INSTALLFILES_LOCATION}/database

echo "oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.1.0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME="`hostname`"
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION="${ORACLE_INVENTORY_LOCATION}"
SELECTED_LANGUAGES=en
ORACLE_HOME="${ORACLE_HOME}"
ORACLE_BASE="${ORACLE_BASE}"
oracle.install.db.InstallEdition=SE
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.DBA_GROUP=dba
oracle.install.db.BACKUPDBA_GROUP=bckpdba
oracle.install.db.DGDBA_GROUP=dgdba
oracle.install.db.KMDBA_GROUP=kmdba
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
oracle.installer.autoupdates.option=SKIP_UPDATES" > ${ORACLE_INSTALLFILES_LOCATION}/db_install.rsp


echo "Now installing Database software. This may take a while..."
su ${ORACLE_USER} -c "cd ${ORACLE_INSTALLFILES_LOCATION}/database; ./runInstaller -showProgress -silent -waitForCompletion -responseFile ${ORACLE_INSTALLFILES_LOCATION}/db_install.rsp"

errorlevel=$?
if [ "$errorlevel" != "0" ] && [ "$errorlevel" != "6" ]; then
  echo "There was an error preventing script from continuing"
  rm -rf ${ORACLE_INSTALLFILES_LOCATION}/database
  exit 1
fi

echo "Installation was a success now doing some house keeping..."
#
# remove the installer files
#
rm -rf ${ORACLE_INSTALLFILES_LOCATION}/database

#
# run the root scripts
#
#${ORACLE_INVENTORY_LOCATION}/orainstRoot.sh
#

#
# This must be run from the $ORACLE_HOME directory
#
echo "changing to directory ${ORACLE_HOME}"
pushd "${ORACLE_HOME}"

# Configure DB software
${ORACLE_HOME}/root.sh

popd


# Update .bash_profile of oracle user
su ${ORACLE_USER} -c "echo '
#Oracle config
export ORACLE_HOME=${ORACLE_HOME}
export PATH=$PATH:\$ORACLE_HOME/bin' >> ~/.bash_profile"



echo "Installation finished. Check the logfiles for errors"
echo "Next steps start a listener, create a service, and finally create a database... "



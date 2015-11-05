# packer
This is a project that uses packer to create a virtualbox machine and vagrant.  Ultimately the image that gets created will be used as a VM in openstack.  

This project is not complete because I'm not including the large files necessary for installing the oracle database softare 12cR1.

Directory Structure

db_installer: is the directory that will be uploaded to the machine during creation time and the scripts in that directory will build and install the oracle database.

http: is the directory that contains the kickstart files that are used to create the initial image

iso: is the directory that contains the oracle oel 6.6 install dvd iso

scripts: is the directory that contains all the scripts that packer uses to execute during the build.

packer-oel-6.json: this file contains all the configuration options used to create the VM.



HOW TO BUILD:
Assumes: virtualbox, vagrant and packer installed
         iso folder has the Oracle_EL_6_6.iso file
         db_installer folder has the linuxamd64_12102_database_se2_1of2.zip and linuxamd64_12102_database_se2_2of2.zip files

packer build -froce -only oel-6-virtbox packer-oel-6.json
or
run the script "create_box.sh"



Output:
oracleDB-oel-6-virtbox-virtualbox.box - Vagrant box.
directory: image_oel_6_virtbox - Which contains the virtualbox ova VM appliance


ToDo:
Create a target and build that does not install vagrant, the virtualbox guest utils and targets an openstack image creation.  However must still have the large preinstall files necessary to install the oracle database


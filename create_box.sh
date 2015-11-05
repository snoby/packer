#!/bin/bash
#
# Assumes you have packer, vagrant, and virtualbox installed on your machine
#

rm oracleDB-oel-6-virtbox-virtualbox.box || true
rm -rf img_oel_6_virtbox

packer build -force -only oel-6-virtbox packer-oel-6.json

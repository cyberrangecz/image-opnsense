#!/bin/sh
set -e

# Set link for Ansible to find python
sudo ln -s /usr/local/bin/python3 /usr/bin/python3

# Setup vtnet1 for DHCP
xml edit --inplace -d '/opnsense/interfaces/vtnet1' /conf/config.xml
xml edit --inplace -s '/opnsense/interfaces' -t elem -n vtnet1 /conf/config.xml
xml edit --inplace -s '/opnsense/interfaces/vtnet1' -t elem -n if -v vtnet1 /conf/config.xml
xml edit --inplace -s '/opnsense/interfaces/vtnet1' -t elem -n descr -v vtnet1 /conf/config.xml
xml edit --inplace -s '/opnsense/interfaces/vtnet1' -t elem -n enable -v 1 /conf/config.xml
xml edit --inplace -s '/opnsense/interfaces/vtnet1' -t elem -n ipaddr -v dhcp /conf/config.xml
xml edit --inplace -s '/opnsense/interfaces/vtnet1' -t elem -n alias-subnet -v 32 /conf/config.xml

# Reinstall pkg to fix segmentation fault of pkg
sudo pkg-static install -fy pkg

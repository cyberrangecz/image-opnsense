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

# Workaround for https://gitlab.ics.muni.cz/muni-kypo-images/opnsense/-/issues/3
xml edit --inplace -s '/opnsense/staticroutes' -t elem -n route /conf/config.xml
xml edit --inplace -s '/opnsense/staticroutes/route[last()]' -t attr -n uuid -v 3f53cb8b-4b68-40e7-ad13-82921fde1cee /conf/config.xml
xml edit --inplace -s '/opnsense/staticroutes/route[last()]' -t elem -n network -v 147.251.4.33/32 /conf/config.xml
xml edit --inplace -s '/opnsense/staticroutes/route[last()]' -t elem -n gateway -v WAN /conf/config.xml
xml edit --inplace -a '/opnsense/staticroutes/route[last()]' -t elem -n route /conf/config.xml
xml edit --inplace -s '/opnsense/staticroutes/route[last()]' -t attr -n uuid -v 44187fd7-ca9a-4daa-a9f9-fccc173dfe53 /conf/config.xml
xml edit --inplace -s '/opnsense/staticroutes/route[last()]' -t elem -n network -v 147.251.6.10/32 /conf/config.xml
xml edit --inplace -s '/opnsense/staticroutes/route[last()]' -t elem -n gateway -v WAN /conf/config.xml

#!/bin/sh
set -e

# Install xmlstarlet
echo "FreeBSD: { enabled: yes }" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg update
pkg install -y xmlstarlet base64
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg update

pkg install -y net/cloud-init os-qemu-guest-agent-1.1
echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf
echo 'qemu_guest_agent_flags="-d -v -l /var/log/qemu-ga.log"' >> /etc/rc.conf
echo 'cloudinit_enable="YES"' >> /etc/rc.conf
cp -f /tmp/cloud.cfg /usr/local/etc/cloud/cloud.cfg

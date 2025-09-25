#!/bin/sh
set -e

# Install xmlstarlet and cloud-init
echo "FreeBSD: { enabled: yes }" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg-static update
pkg-static install -y xmlstarlet base64 py311-cloud-init-24.1.4_4
echo 'cloudinit_enable="YES"' >> /etc/rc.conf
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg-static update

pkg-static install -y os-qemu-guest-agent-1.3
echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf
echo 'qemu_guest_agent_flags="-d -v -l /var/log/qemu-ga.log"' >> /etc/rc.conf
cp -f /tmp/cloud.cfg /usr/local/etc/cloud/cloud.cfg

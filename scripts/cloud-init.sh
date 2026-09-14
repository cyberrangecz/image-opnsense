#!/bin/sh
set -e

# Install cloud-init dependencies
echo "FreeBSD: { enabled: yes }" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg-static update -f
pkg-static install -y xmlstarlet base64


# cloud-init from pkg
python3.13 -m venv /usr/local/cloud-init
cd /usr/local/cloud-init
. ./bin/activate
fetch -o cloud-init-25.2.tar.gz https://github.com/canonical/cloud-init/archive/refs/tags/25.2.tar.gz && tar xzf cloud-init-25.2.tar.gz
cd cloud-init-25.2
pip install 'jsonschema<4.18'
pip install -r requirements.txt
python setup.py install --init-system sysvinit_freebsd
echo 'cloudinit_enable="YES"' >> /etc/rc.conf
mkdir -p /usr/local/etc/cloud/
cp -f /tmp/cloud.cfg /usr/local/etc/cloud/cloud.cfg

echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg-static update -f

pkg-static install -y os-qemu-guest-agent #-1.3
echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf
echo 'qemu_guest_agent_flags="-d -v -l /var/log/qemu-ga.log"' >> /etc/rc.conf

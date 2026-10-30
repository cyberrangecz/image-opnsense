#!/bin/sh
set -e

# Temporarily enable the FreeBSD ports repository. OPNsense 26.7 is based on
# FreeBSD 15, where the repository is called FreeBSD-ports (FreeBSD on <=14).
REPOS_CONF=/usr/local/etc/pkg/repos/FreeBSD.conf
cp "${REPOS_CONF}" /tmp/FreeBSD.conf.orig
cat > "${REPOS_CONF}" <<EOF
FreeBSD-ports: { enabled: yes }
FreeBSD-ports-kmods: { enabled: no }
FreeBSD: { enabled: no }
FreeBSD-kmods: { enabled: no }
EOF
pkg-static update -f

# Install cloud-init dependencies
pkg-static install -y xmlstarlet python312

# FreeBSD builds python modules only for py312, while OPNsense ships py313.
# These three py312 packages install the same scripts into /usr/local/bin as
# their installed py313 counterparts, and that conflict makes pkg silently drop
# cloud-init from the install plan. Forced mode skips the conflicting files
# and keeps the py313 ones.
mkdir -p /tmp/pkg-conflicts
pkg-static fetch -y -r FreeBSD-ports -o /tmp/pkg-conflicts py312-idna py312-charset-normalizer py312-Babel
for p in $(find /tmp/pkg-conflicts -name '*.pkg'); do
	pkg-static add -f "${p}"
done
rm -rf /tmp/pkg-conflicts

# cloud-init from pkg
pkg-static install -y py312-cloud-init
# pkg exits 0 even when it drops a package from the plan, so check explicitly
pkg-static info -e py312-cloud-init
echo 'cloudinit_enable="YES"' >> /etc/rc.conf
# Keep the package's default cloud.cfg, only add OPNsense overrides
cp -f /tmp/cloud-init/90_opnsense.cfg /usr/local/etc/cloud/cloud.cfg.d/
mkdir -p /var/lib/cloud/scripts/per-instance
install -m 755 /tmp/cloud-init/opnsense-user.sh /var/lib/cloud/scripts/per-instance/

# Restore OPNsense's repository configuration (FreeBSD repositories disabled)
cp -f /tmp/FreeBSD.conf.orig "${REPOS_CONF}"
pkg-static update -f

pkg-static install -y os-qemu-guest-agent
# Register the plugin in config.xml like the firmware GUI does after install,
# otherwise it is listed as misconfigured
/usr/local/opnsense/scripts/firmware/register.php install os-qemu-guest-agent

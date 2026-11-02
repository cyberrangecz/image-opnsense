#!/bin/sh
set -e

CLOUD_INIT_VERSION=25.2
CLOUD_INIT_SHA256=a5f4752ac86efa395c99151f787072159b86277201d8386d90019db01cdd9779
VENV=/usr/local/cloud-init
PREFIX=/usr/local

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

# xmlstarlet is used by /var/lib/cloud/scripts/per-instance/opnsense-user.sh
pkg-static install -y xmlstarlet

# Restore OPNsense's repository configuration (FreeBSD repositories disabled)
cp -f /tmp/FreeBSD.conf.orig "${REPOS_CONF}"
pkg-static update -f

# cloud-init is not installed from the FreeBSD py312-cloud-init package. Its
# py312-* dependencies come from a repository that is disabled afterwards and
# clash with OPNsense's py313-* packages: they share files in /usr/local/bin,
# and OPNsense updates deinstall some of them (py312-cffi), breaking the
# dependencies of the rest. Instead cloud-init and its dependencies live in a
# venv on OPNsense's own python, invisible to pkg, laid out like the package.
PYTHON=$(realpath /usr/local/bin/python3)
# Keep the python package when an OPNsense update moves to a newer python,
# otherwise pkg autoremove would take the venv's interpreter with it
pkg-static set -y -A 0 "$(pkg-static which -q "${PYTHON}")"

"${PYTHON}" -m venv "${VENV}"
# jsonschema>=4.18 needs rpds-py, which has to be built with Rust
"${VENV}/bin/pip" install --no-cache-dir 'jsonschema<4.18' \
	jinja2 oauthlib 'configobj>=5.0.2' pyyaml requests jsonpatch

SRC=/tmp/cloud-init-${CLOUD_INIT_VERSION}
fetch -o "${SRC}.tar.gz" "https://github.com/canonical/cloud-init/archive/refs/tags/${CLOUD_INIT_VERSION}.tar.gz"
sha256 -q -c "${CLOUD_INIT_SHA256}" "${SRC}.tar.gz"
tar -xzf "${SRC}.tar.gz" -C /tmp
cd "${SRC}"
# FreeBSD-specific patches of the net/cloud-init port
for p in /tmp/cloud-init/patches/patch-*; do
	patch -s -p0 < "${p}"
done
sed -i '' "s|@@PACKAGED_VERSION@@|${CLOUD_INIT_VERSION}|" cloudinit/version.py
"${VENV}/bin/pip" install --no-cache-dir --no-deps .

# System files where the package puts them (setup.py would render the venv as
# prefix into the rc.d scripts)
for s in cloud-init cloud-id cloud-init-per; do
	ln -sf "${VENV}/bin/${s}" "${PREFIX}/bin/${s}"
done
render() {
	"${VENV}/bin/python" tools/render-template --variant freebsd --prefix "${PREFIX}" "$@"
}
for t in sysvinit/freebsd/*.tmpl; do
	f=$(basename "${t}" .tmpl)
	render "${t}" "${PREFIX}/etc/rc.d/${f}"
	chmod 755 "${PREFIX}/etc/rc.d/${f}"
done
mkdir -p "${PREFIX}/etc/cloud/cloud.cfg.d" "${PREFIX}/etc/cloud/clean.d" \
	"${PREFIX}/etc/cloud/templates" "${PREFIX}/lib/cloud-init"
render --is-yaml config/cloud.cfg.tmpl "${PREFIX}/etc/cloud/cloud.cfg"
cp config/cloud.cfg.d/* "${PREFIX}/etc/cloud/cloud.cfg.d/"
cp templates/* "${PREFIX}/etc/cloud/templates/"
install -m 755 tools/ds-identify tools/hook-hotplug tools/uncloud-init \
	tools/write-ssh-key-fingerprints "${PREFIX}/lib/cloud-init/"
# Added by the port as files/patch-config_cloud.cfg.d_99__freebsd.cfg
cat > "${PREFIX}/etc/cloud/cloud.cfg.d/99_freebsd.cfg" <<EOF
no_ssh_fingerprints: true
disable_network_activation: true
EOF
cd /
rm -rf "${SRC}" "${SRC}.tar.gz"

"${PREFIX}/bin/cloud-init" --version
echo 'cloudinit_enable="YES"' >> /etc/rc.conf
# OPNsense overrides of the FreeBSD defaults in cloud.cfg
cp -f /tmp/cloud-init/90_opnsense.cfg /usr/local/etc/cloud/cloud.cfg.d/
mkdir -p /var/lib/cloud/scripts/per-instance
install -m 755 /tmp/cloud-init/opnsense-user.sh /var/lib/cloud/scripts/per-instance/

pkg-static install -y os-qemu-guest-agent
# Register the plugin in config.xml like the firmware GUI does after install,
# otherwise it is listed as misconfigured
/usr/local/opnsense/scripts/firmware/register.php install os-qemu-guest-agent
